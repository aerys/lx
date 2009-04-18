<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.promethe.net">

  <xsl:output ommit-xml-declaration="yes"
	      method="text"
	      encoding="utf-8"/>

  <xsl:include href="lx.xsl"/>

  <xsl:template match="lx:project">
    <!-- <?php -->
    <xsl:value-of select="concat($LX_LT, '?php', $LX_LF, $LX_LF)"/>

    <xsl:apply-templates select="lx:const"/>

    <!-- load LX -->
    <xsl:text>require_once (LX_ROOT . '/src/misc/lx-config.php');</xsl:text>
    <xsl:value-of select="$LX_LF"/>

    <!-- set database configurations -->
    <xsl:apply-templates select="lx:database"/>

    <!-- set controlers map -->
    <xsl:apply-templates select="lx:controler"/>

    <xsl:value-of select="concat($LX_LF, '?', $LX_GT)"/>
    <!-- ?> -->
  </xsl:template>

  <xsl:template match="lx:project/@debug">
    <xsl:text>define('LX_DEBUG', </xsl:text>
    <xsl:choose>
      <xsl:when test=". = 'true'">
	<xsl:text>true</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>false</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="concat(');', $LX_LF)"/>
  </xsl:template>

  <xsl:template match="lx:const[@name][@value]">
    <xsl:text>define('</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>', </xsl:text>
    <xsl:value-of select="@value"/>
    <xsl:text>);</xsl:text>
    <xsl:value-of select="$LX_LF"/>
  </xsl:template>

  <xsl:template match="lx:database">
    <xsl:text>$_LX['DATABASES']['</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>'] = array(</xsl:text>
    <xsl:call-template name="lx:foreach">
      <xsl:with-param name="collection" select="@*"/>
      <xsl:with-param name="delimiter" select="', '"/>
    </xsl:call-template>
    <xsl:value-of select="concat(');', $LX_LF)"/>
  </xsl:template>

  <xsl:template match="lx:database/@*">
    <xsl:value-of select="concat($LX_QUOTE, name(), $LX_QUOTE, ' => ')"/>
    <xsl:value-of select="concat($LX_QUOTE, current(), $LX_QUOTE)"/>
  </xsl:template>

  <xsl:template match="lx:controler">
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

    <xsl:text>$_LX['CONTROLLERS']['</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>'] = array('class' => '</xsl:text>
    <xsl:value-of select="$class"/>
    <xsl:text>'</xsl:text>

    <xsl:call-template name="lx:foreach">
      <xsl:with-param name="begin">
	<xsl:text>, 'filters' => array(</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="collection" select="lx:filter"/>
      <xsl:with-param name="delimiter" select="', '"/>
      <xsl:with-param name="end" select="')'"/>
    </xsl:call-template>

    <xsl:value-of select="concat(');', $LX_LF)"/>
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
    <xsl:text> => </xsl:text>
    <xsl:value-of select="concat($LX_QUOTE, $class, $LX_QUOTE)"/>
  </xsl:template>

</xsl:stylesheet>
