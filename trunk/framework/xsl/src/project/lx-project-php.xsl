<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.aerys.in">

  <xsl:output ommit-xml-declaration="yes"
	      method="text"
	      encoding="utf-8"/>

  <xsl:include href="../lx-std.xsl"/>

  <xsl:variable name="LX_PROJECT_ROOT_NODE" select="/"/>

  <xsl:template match="/">
    <xsl:if test=". = $LX_PROJECT_ROOT_NODE">
      <!-- <?php -->
      <xsl:value-of select="concat($LX_LT, '?php', $LX_LF, $LX_LF)"/>

      <xsl:if test="not(lx:const[@name='LX_APPLICATION_ROOT'])">
        <xsl:text>define('LX_APPLICATION_ROOT',realpath(dirname(__FILE__) . '/..'));</xsl:text>
        <xsl:value-of select="$LX_LF"/>
      </xsl:if>
      <xsl:if test="not(lx:const[@name='LX_ROOT'])">
        <xsl:text>define('LX_ROOT',realpath(dirname(__FILE__) . '/../lib/lx'));</xsl:text>
        <xsl:value-of select="$LX_LF"/>
      </xsl:if>

    <!-- load LX -->
    <xsl:text>require_once(LX_ROOT . '/php/src/misc/lx-bootstrap.php');</xsl:text>
    <xsl:value-of select="$LX_LF"/>
    </xsl:if>

    <xsl:apply-templates select="lx:project"/>

    <xsl:if test=". = $LX_PROJECT_ROOT_NODE">
      <xsl:text>require_once(LX_ROOT . '/php/src/misc/lx-configure.php');</xsl:text>
      <xsl:value-of select="$LX_LF"/>
      <xsl:value-of select="concat($LX_LF, '?', $LX_GT)"/>
    </xsl:if>
    <!-- ?> -->
  </xsl:template>

  <xsl:template match="lx:project">
    <xsl:apply-templates select="lx:const"/>
    <xsl:apply-templates select="lx:database"/>
    <xsl:apply-templates select="lx:response"/>
    <xsl:apply-templates select="lx:map"/>
    <xsl:apply-templates select="lx:include"/>
  </xsl:template>

  <xsl:template match="lx:map">
    <xsl:apply-templates select="lx:filter"/>
    <xsl:apply-templates select="lx:controller"/>
    <xsl:apply-templates select="lx:module"/>
  </xsl:template>

  <xsl:template match="lx:map/lx:filter">
    <xsl:text>$_LX['map']['filters']['</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>']='</xsl:text>
    <xsl:choose>
      <xsl:when test="@class">
	<xsl:value-of select="@class"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="lx:ucfirst">
	  <xsl:with-param name="string" select="@name"/>
	</xsl:call-template>
	<xsl:text>Filter</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="concat($LX_QUOTE, ';', $LX_LF)"/>
  </xsl:template>

  <xsl:template match="lx:const[@name][@value]">
    <xsl:text>define('</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>',</xsl:text>
    <xsl:value-of select="@value"/>
    <xsl:text>);</xsl:text>
    <xsl:value-of select="$LX_LF"/>
  </xsl:template>

  <xsl:template match="lx:response">
    <xsl:if test="@default='true'">
      <xsl:text>$_LX['responses'][LX_DEFAULT_EXTENSION]=</xsl:text>
    </xsl:if>
    <xsl:text>$_LX['responses']['</xsl:text>
    <xsl:value-of select="@extension"/>
    <xsl:text>']='</xsl:text>
    <xsl:value-of select="concat(@handler, $LX_QUOTE, ';', $LX_LF)"/>
  </xsl:template>

  <xsl:template match="lx:database">
    <xsl:text>$_LX['databases']['</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>']=array(</xsl:text>
    <xsl:call-template name="lx:for-each">
      <xsl:with-param name="collection" select="@*"/>
      <xsl:with-param name="delimiter" select="','"/>
    </xsl:call-template>
    <xsl:value-of select="concat(');', $LX_LF)"/>
  </xsl:template>

  <xsl:template match="lx:database/@*">
    <xsl:value-of select="concat($LX_QUOTE, name(), $LX_QUOTE, '=>')"/>
    <xsl:value-of select="concat($LX_QUOTE, current(), $LX_QUOTE)"/>
  </xsl:template>

  <xsl:template match="lx:controller">
    <xsl:variable name="module" select="ancestor::lx:module"/>

    <xsl:variable name="class">
      <xsl:choose>
	<xsl:when test="@class">
	  <xsl:value-of select="@class"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:call-template name="lx:ucfirst">
	    <xsl:with-param name="string" select="@name"/>
	  </xsl:call-template>
	  <xsl:text>Controller</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="varName">
      <xsl:text>$_LX['map']</xsl:text>
      <xsl:if test="$module">
        <xsl:text>['modules']['</xsl:text>
        <xsl:value-of select="ancestor::lx:module/@name"/>
        <xsl:text>']</xsl:text>
      </xsl:if>
      <xsl:text>['controllers']['</xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:text>']</xsl:text>
    </xsl:variable>

    <xsl:value-of select="$varName"/>
    <xsl:text>=array('class'=>'</xsl:text>
    <xsl:value-of select="$class"/>

    <!-- actions -->
    <xsl:text>','default_action'=>'</xsl:text>
    <xsl:value-of select="./lx:action[@default='true'][last()]/@name"/>
    <xsl:text>','actions'=>array()</xsl:text>

    <xsl:call-template name="filters"/>
    <xsl:apply-templates select="@view|@layout|@template"/>

    <xsl:text>);</xsl:text>

    <xsl:value-of select="$LX_LF"/>

    <xsl:apply-templates select="lx:action"/>
    <xsl:apply-templates select="lx:alias"/>

    <xsl:if test="@default = 'true'">
      <xsl:text>$_LX['map']</xsl:text>
      <xsl:if test="$module">
        <xsl:text>['modules']['</xsl:text>
        <xsl:value-of select="ancestor::lx:module/@name"/>
        <xsl:text>']</xsl:text>
      </xsl:if>
      <xsl:text>['controllers'][LX_DEFAULT_CONTROLLER]=</xsl:text>
      <xsl:value-of select="$varName"/>
      <xsl:text>;</xsl:text>
      <xsl:value-of select="$LX_LF"/>
    </xsl:if>

  </xsl:template>

  <xsl:template match="lx:module">
    <xsl:variable name="varName">
      <xsl:text>$_LX['map']['modules']['</xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:text>']</xsl:text>
    </xsl:variable>

    <xsl:value-of select="$varName"/>
    <xsl:text>=array('controllers'=>array()</xsl:text>
    <xsl:if test="@lx:controller[@default='true']">
      <xsl:text>,'default_controller'=>'</xsl:text>
      <xsl:value-of select="@lx:controller[@default='true'][last()]/@name"/>
      <xsl:text>'</xsl:text>
    </xsl:if>

    <xsl:call-template name="filters"/>
    <xsl:apply-templates select="@view|@layout|@template"/>

    <xsl:text>);</xsl:text>

    <xsl:value-of select="$LX_LF"/>
    <xsl:apply-templates select="lx:controller"/>
    <xsl:apply-templates select="@default-controller"/>

    <xsl:apply-templates select="lx:alias"/>

    <xsl:if test="@default='true'">
      <xsl:text>$_LX['map']['modules'][LX_DEFAULT_MODULE]=</xsl:text>
      <xsl:value-of select="$varName"/>
      <xsl:text>;</xsl:text>
    <xsl:value-of select="$LX_LF"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="lx:controller/lx:alias">
    <xsl:variable name="module" select="ancestor::lx:module"/>
    <xsl:variable name="controller" select="ancestor::lx:controller"/>
    <xsl:variable name="base">
      <xsl:text>$_LX['map']['</xsl:text>

      <xsl:if test="$module">
	<xsl:text>modules']['</xsl:text>
	<xsl:value-of select="$module/@name"/>
	<xsl:text>']['</xsl:text>
      </xsl:if>

      <xsl:text>controllers']['</xsl:text>
    </xsl:variable>

    <xsl:value-of select="$base"/>
    <xsl:value-of select="@name"/>
    <xsl:text>']=</xsl:text>
    <xsl:value-of select="$base"/>
    <xsl:value-of select="$controller/@name"/>
    <xsl:text>'];</xsl:text>

    <xsl:value-of select="$LX_LF"/>
  </xsl:template>

  <xsl:template match="lx:module/lx:alias">
    <xsl:variable name="base">
      <xsl:text>$_LX['map']['modules']['</xsl:text>
    </xsl:variable>

    <xsl:value-of select="$base"/>
    <xsl:value-of select="@name"/>
    <xsl:text>']=</xsl:text>
    <xsl:value-of select="$base"/>
    <xsl:value-of select="ancestor::lx:module/@name"/>
    <xsl:text>'];</xsl:text>

    <xsl:value-of select="$LX_LF"/>
  </xsl:template>

  <xsl:template match="lx:action">
    <xsl:variable name="module" select="ancestor::lx:module/@name"/>
    <xsl:variable name="controller" select="ancestor::lx:controller/@name"/>

    <xsl:text>$_LX['map']</xsl:text>
    <xsl:if test="$module">
      <xsl:text>['modules']['</xsl:text>
      <xsl:value-of select="ancestor::lx:module/@name"/>
      <xsl:text>']</xsl:text>
    </xsl:if>

    <xsl:text>['controllers']['</xsl:text>
    <xsl:value-of select="$controller"/>
    <xsl:text>']['actions']['</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>']=</xsl:text>

    <xsl:text>array('method'=>'</xsl:text>
    <xsl:choose>
      <xsl:when test="@method!=''">
	<xsl:value-of select="@method"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="@name"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>'</xsl:text>

    <xsl:call-template name="filters"/>
    <xsl:apply-templates select="@view|@layout|@template"/>

    <xsl:text>);</xsl:text>

    <xsl:value-of select="$LX_LF"/>
  </xsl:template>

  <xsl:template name="filters">
    <xsl:if test="lx:filter">
      <xsl:text>,'filters'=>array(</xsl:text>
      <xsl:call-template name="lx:for-each">
        <xsl:with-param name="collection" select="lx:filter"/>
        <xsl:with-param name="delimiter" select="','"/>
      </xsl:call-template>
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="lx:filter">
    <xsl:variable name="class">
      <xsl:choose>
	<xsl:when test="@class">
	  <xsl:value-of select="@class"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:call-template name="lx:ucfirst">
	    <xsl:with-param name="string" select="@name"/>
	  </xsl:call-template>
	  <xsl:text>Filter</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:value-of select="concat($LX_QUOTE, @name, $LX_QUOTE)"/>
    <xsl:text>=></xsl:text>
    <xsl:value-of select="concat($LX_QUOTE, $class, $LX_QUOTE)"/>
  </xsl:template>

  <xsl:template match="@view | @layout | @template">
    <xsl:text>,'</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>'=>'</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>'</xsl:text>
  </xsl:template>

</xsl:stylesheet>
