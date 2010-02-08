<?xml version="1.0" encoding="utf-8"?>

<?xml-stylesheet type="text/xsl" href="lx-xsldoc.xsl"?>

<!--
    @stylesheet LX HTML4
    HTML4 templates.
-->
<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.aerys.in"
		xmlns:lx.html="http://lx.aerys.in/html"
		xmlns:lx.html.flash="http://lx.aerys.in/html/flash">

  <xsl:output method="html"
	      version="4.0"
	      omit-xml-declaration="yes"
	      doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"
	      doctype-system="http://www.w3.org/TR/html4/loose.dtd"
	      indent="yes"
	      encoding="unicode"/>

  <xsl:include href="lx-std.xsl"/>
  <xsl:include href="lx-response.xsl"/>

  <xsl:template match="/">
    <html>
      <head>

	<meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>

	<base>
	  <xsl:attribute name="href">
	    <xsl:text>http://</xsl:text>
	    <xsl:value-of select="$LX_RESPONSE/@host"/>
	    <xsl:if test="$LX_RESPONSE/@document-root != '/'">
	      <xsl:value-of select="$LX_RESPONSE/@document-root"/>
	    </xsl:if>
	    <xsl:text>/</xsl:text>
	  </xsl:attribute>
	</base>

	<title>
	  <xsl:apply-templates select="$LX_LAYOUT/head/title/node()"/>
	  <xsl:apply-templates select="$LX_TEMPLATE/head/title/node()"/>
	</title>

	<xsl:apply-templates select="$LX_LAYOUT/head/*[name()!='title']"/>
	<xsl:apply-templates select="$LX_TEMPLATE/head/*[name()!='title']"/>

      </head>
      <body>
	<xsl:copy-of select="$LX_LAYOUT/body/@* | $LX_TEMPLATE/body/@*"/>

	<xsl:apply-templates select="$LX_LAYOUT/body/node()"/>
      </body>
    </html>
  </xsl:template>

  <!-- BEGIN IDENTITY -->
  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|comment()|processing-instruction()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:if test="normalize-space(.) != '' or not(following-sibling::lx:text or preceding-sibling::lx:text)">
      <xsl:copy>
	<xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  <!-- END IDENTITY -->

  <!--
      @template lx:template
      Default template template.
    -->
  <xsl:template match="lx:template">
    <xsl:apply-templates select="body/node()"/>
  </xsl:template>

  <!--
      @template lx:error
    -->
  <xsl:template match="lx:error">
    <div class="error">
      <em>ERROR: </em>
      <xsl:value-of select="message"/>
      <pre>
	<xsl:value-of select="trace"/>
      </pre>
    </div>
  </xsl:template>

  <!--
      @template lx.html:javascript-class
      Include a javascript class.
    -->
  <xsl:template name="lx.html:javascript-class"
		match="lx.html:javascript-class">
    <!-- @param name of the javascript class -->
    <xsl:param name="name" select="@name"/>

    <script language="javascript" type="text/javascript"
	    src="javascript/class/{$name}.js"></script>
    <xsl:value-of select="$LX_LF"/>
  </xsl:template>

  <!--
      @template lx.html:javascript-library
      Include a javascript library.
    -->
  <xsl:template name="lx.html:javascript-library"
		match="lx.html:javascript-library">
    <!-- @param name of the javascript library -->
    <xsl:param name="name" select="@name"/>

    <script language="javascript" type="text/javascript"
	    src="javascript/libs/{$name}.js"></script>
    <xsl:value-of select="$LX_LF"/>
  </xsl:template>

  <!--
      @template lx.html:javascript
      Embed javascript code.
    -->
  <xsl:template name="lx.html:javascript"
		match="lx.html:javascript">
    <!-- @param javascript code to embed -->
    <xsl:param name="script"/>

    <script language="javascript" type="text/javascript">
      <xsl:choose>
	<xsl:when test="$script != ''">
	  <xsl:value-of select="$script"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:apply-templates select="node()"/>
	</xsl:otherwise>
      </xsl:choose>
    </script>
  </xsl:template>

  <!--
      @template lx.html:favicon
      Set the page favicon.
    -->
  <xsl:template match="lx.html:favicon"
		name="lx.html:favicon">
    <xsl:param name="href" select="@href"/>

    <link rel="icon" href="{$href}"/>
  </xsl:template>

  <!--
      @template lx.html:skin
    -->
  <xsl:template match="lx.html:skin"
		name="lx.html:skin">
    <xsl:apply-templates select="lx.html:stylesheet">
      <xsl:with-param name="skin">
	<xsl:apply-templates select="@name" mode="lx:value-of"/>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <!--
      @template lx.html:stylesheet
      Include a CSS stylesheet.
    -->
  <xsl:template name="lx.html:stylesheet"
		match="lx.html:stylesheet">
    <!-- @param name of the CSS stylesheet -->
    <xsl:param name="name" select="@name"/>
    <!-- @param name of the skin -->
    <xsl:param name="skin">
      <xsl:apply-templates select="@skin" mode="lx:value-of"/>
    </xsl:param>

    <xsl:variable name="skin_path">
      <xsl:if test="$skin != ''">
	<xsl:value-of select="$skin"/>
	<xsl:text>/</xsl:text>
      </xsl:if>
    </xsl:variable>

    <link rel="stylesheet" type="text/css" href="styles/{$skin_path}{$name}.css"/>
    <xsl:value-of select="$LX_LF"/>
  </xsl:template>

  <!--
      @template lx.html:css
      Include a CSS style declaration
    -->
  <xsl:template name="lx.html:style"
		match="lx.html:style">
    <!-- @param style declaration -->
    <xsl:param name="style" select="text()"/>

    <style type="text/css">
      <xsl:copy-of select="$style"/>
    </style>
  </xsl:template>

  <!--
      @template lx.html:link-controller
      Create a link to a controller.
    -->
  <xsl:template match="lx.html:link[@controller] | lx.html:link[@module] | lx.html:link[@action]"
		name="lx.html:link-controller">
    <!-- @param module name -->
    <xsl:param name="module">
      <xsl:apply-templates select="@module" mode="lx:value-of"/>
    </xsl:param>
    <!-- @param controller name -->
    <xsl:param name="controller">
      <xsl:apply-templates select="@controller" mode="lx:value-of"/>
    </xsl:param>
    <!-- @param action to call -->
    <xsl:param name="action">
      <xsl:apply-templates select="@action" mode="lx:value-of"/>
    </xsl:param>
    <!-- @param action arguments -->
    <xsl:param name="arguments" select="lx:argument"/>
    <!-- @param content of the link (string | node)-->
    <xsl:param name="content"/>

    <xsl:variable name="url">
      <xsl:if test="$module != ''">
	<xsl:value-of select="$module"/>
	<xsl:if test="$controller != ''">
	  <xsl:text>/</xsl:text>
	</xsl:if>
      </xsl:if>
      <xsl:if test="$controller != ''">
	<xsl:value-of select="$controller"/>
	<xsl:if test="$action != ''">
	  <xsl:text>/</xsl:text>
	</xsl:if>
      </xsl:if>
      <xsl:if test="$action != ''">
	<xsl:value-of select="$action"/>
      </xsl:if>
      <xsl:call-template name="lx:for-each">
	<xsl:with-param name="begin" select="'/'"/>
	<xsl:with-param name="delimiter" select="'/'"/>
	<xsl:with-param name="collection" select="$arguments"/>
      </xsl:call-template>
      <xsl:if test="$LX_RESPONSE/lx:request/@handler!='xsl'">
	<xsl:value-of select="concat('.', $LX_RESPONSE/lx:request/@handler)"/>
      </xsl:if>
    </xsl:variable>

    <a href="{$url}">
      <xsl:choose>
	<xsl:when test="not($content)">
	  <xsl:apply-templates select="node()[name()!='lx:argument']"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="normalize-space($content)"/>
	</xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:template>

  <xsl:template match="lx:argument">
    <xsl:value-of select="@name"/>
    <xsl:text>=</xsl:text>
    <xsl:value-of select="@value"/>
  </xsl:template>

  <!--
      @template lx.html:link
      Create a link.
    -->
  <xsl:template match="lx.html:link[@href]"
		name="lx.html:link">
    <!-- @param URL of the link -->
    <xsl:param name="href">
      <xsl:apply-templates select="@href" mode="lx:value-of"/>
    </xsl:param>
    <!-- @param content of the link -->
    <xsl:param name="content" select="node()"/>
    <!-- @param target of the link ('_blank' | '_parent') -->
    <xsl:param name="target" select="@target"/>

    <xsl:element name="a">
      <xsl:attribute name="href">
	<xsl:value-of select="$href"/>
	<xsl:if test="$LX_RESPONSE/lx:request/@handler!='xsl' and $target!='_blank'">
	  <xsl:value-of select="concat('.', $LX_RESPONSE/lx:request/@handler)"/>
	</xsl:if>
      </xsl:attribute>

      <xsl:if test="$target!='' and $target!='_self'">
	<xsl:attribute name="target">
	  <xsl:value-of select="$target"/>
	</xsl:attribute>
      </xsl:if>

      <xsl:choose>
	<xsl:when test="$content = node()">
	  <xsl:apply-templates select="node()"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$content"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <!--
      @template lx.html.flash:flash
      Insert Flash content.
    -->
  <xsl:template match="lx.html.flash:flash"
                name="lx.html.flash:flash">
    <!-- @param id of the application -->
    <xsl:param name="id" select="@id"/>
    <!-- @param ressource name (without 'flash/' and '.swf') of the SWF file -->
    <xsl:param name="name">
      <xsl:apply-templates select="@name" mode="lx:value-of"/>
    </xsl:param>
    <!-- @param javascript code to execute when the application is ready -->
    <xsl:param name="script" select="text()"/>
    <!-- @param width of the application -->
    <xsl:param name="width" select="@width"/>
    <!-- @param height of the application -->
    <xsl:param name="height" select="@height"/>
    <!-- @param flashvars -->
    <xsl:param name="flashvars" select="lx.html.flash:flashvar"/>
    <!-- @param wmode -->
    <xsl:param name="wmode">
      <xsl:choose>
	<xsl:when test="@wmode!=''">
	  <xsl:value-of select="@wmode"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>opaque</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:param>

    <xsl:variable name="swf">
      <xsl:text>http://</xsl:text>
      <xsl:value-of select="$LX_RESPONSE/@host"/>
      <xsl:value-of select="$LX_RESPONSE/@document-root"/>
      <xsl:text>flash/</xsl:text>
      <xsl:value-of select="$name"/>
    </xsl:variable>

    <xsl:variable name="flashvars_full">
      <xsl:if test="$script">
	<xsl:text>bridgeName=</xsl:text>
	<xsl:value-of select="$id"/>
	<xsl:if test="$flashvars">
	  <xsl:text>&amp;</xsl:text>
	</xsl:if>
      </xsl:if>
      <xsl:apply-templates select="$flashvars"/>
    </xsl:variable>

    <object type="application/x-shockwave-flash" data="{$swf}.swf" width="{$width}" height="{$height}" id="{$id}">
      <param name="movie" value="{$swf}.swf" />
      <param name="allowScriptAccess" value="sameDomain" />
      <param name="allowFullscreen" value="true" />
      <param name="flashvars" value="{$flashvars_full}" />
      <param name="wmode" value="{$wmode}" />
      <param name="name" value="{$id}"/>

      <xsl:apply-templates select="lx.html.flash:alternative-content"/>
    </object>

    <xsl:apply-templates select="lx.html.flash:fabridge"/>
  </xsl:template>

  <xsl:template match="lx.html.flash:alternative-content">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="lx.html.flash:fabridge">
    <!-- FIXME -->
  </xsl:template>

  <!--
      @template lx.html.flash:flashvar
    -->
  <xsl:template match="lx.html.flash:flashvar">
    <xsl:variable name="value">
      <xsl:apply-templates select="@value" mode="lx:value-of"/>
    </xsl:variable>

    <xsl:if test="preceding-sibling::lx.html.flash:flashvar">
      <xsl:value-of select="$LX_AMP"/>
    </xsl:if>
    <xsl:value-of select="concat(@name, '=', $value)"/>
  </xsl:template>

  <!--
      lx.html.flash:fabridge
      Set a Flex-Ajax bridge using the FABridge library provided with the Flex SDK.
      The content of this markup must be JavaScript code. The Flex application is
      accessible using an object named by the id attribute specified in the parent
      lx.html.flash:flash node.
    -->
  <xsl:template match="lx.html.flash:fabridge">
    <xsl:param name="bridgeName" select="../@id"/>
    <xsl:param name="script" select="node()"/>

    <xsl:variable name="callback">
      FABridge.addInitializationCallback('<xsl:value-of select="$bridgeName"/>',
      function()
      {
        window.<xsl:value-of select="$bridgeName"/> = FABridge['<xsl:value-of select="$bridgeName"/>'].root();
        <xsl:apply-templates select="$script"/>
      });
    </xsl:variable>

    <xsl:call-template name="lx.html:javascript">
      <xsl:with-param name="script" select="normalize-space($callback)"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
