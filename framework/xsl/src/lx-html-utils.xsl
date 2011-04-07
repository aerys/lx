<?xml version="1.0" encoding="utf-8"?>

<?xml-stylesheet type="text/xsl" href="lx-xsldoc.xsl"?>

<!--
    @stylesheet LX HTML UTILS
    HTML UTILS templates.
-->
<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.aerys.in"
		xmlns:lx.html="http://lx.aerys.in/html">

  <xsl:output method="html"
	    omit-xml-declaration="yes"
	    indent="yes" />

  <xsl:template name="lx.html:detect-client-xsl-support">
    <xsl:if test="not($LX_RESPONSE/lx:request/@clientXslSupport)">
      <xsl:variable name="script">
        <![CDATA[
        try
        {
          var e = document.createElement("script");

          e.setAttribute("type", "text/javascript");

          if (window.XSLTProcessor ||
              (window.ActiveXObject && new ActiveXObject("Microsoft.XMLDOM")))
          {
            e.setAttribute("src", "?LX_ENABLE_CLIENT_XSL_SUPPORT");
          }
          else
          {
            e.setAttribute("src", "?LX_DISABLE_CLIENT_XSL_SUPPORT");
          }
          document.getElementsByTagName("head")[0].appendChild(e);
        }
        catch (e) { }
      ]]>
      </xsl:variable>

      <xsl:call-template name="lx.html:javascript">
        <xsl:with-param name="script" select="normalize-space($script)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

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
      @template lx.html:javascript
      Embed javascript code.
    -->
  <xsl:template name="lx.html:javascript"
		match="lx.html:javascript">
    <!-- @param javascript code to embed -->
    <xsl:param name="script" select="node()"/>

    <script language="javascript" type="text/javascript">
      <xsl:choose>
        <xsl:when test="@name">
          <xsl:attribute name="src">
            <xsl:text>javascript/</xsl:text>
            <xsl:value-of select="@name"/>
            <xsl:text>.js</xsl:text>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="node() = $script">
          <xsl:apply-templates select="$script"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$script"/>
        </xsl:otherwise>
      </xsl:choose>
    </script>
    <xsl:value-of select="$LX_LF"/>
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
  <xsl:template match="lx.html:a[@controller] | lx.html:a[@module] | lx.html:a[@action]"
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
    <xsl:param name="arguments" select="lx.html:argument"/>
    <!-- @param content of the link (string or node set)-->
    <xsl:param name="content"/>

    <xsl:variable name="url">
      <xsl:if test="$module != ''">
	<xsl:value-of select="$module"/>
	<xsl:if test="$controller != '' or $action != ''">
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
      <xsl:if test="$LX_RESPONSE/lx:request/@extension!='xsl'">
	<xsl:value-of select="concat('.', $LX_RESPONSE/lx:request/@extension)"/>
      </xsl:if>
    </xsl:variable>

    <a href="{$url}">
      <xsl:choose>
	<xsl:when test="not($content)">
	  <xsl:apply-templates select="node()[local-name()!='argument']"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="normalize-space($content)"/>
	</xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:template>

  <xsl:template match="lx.html:argument">
    <xsl:if test="@name!='' and @method='GET'">
      <xsl:value-of select="@name"/>
      <xsl:text>=</xsl:text>
    </xsl:if>
    <xsl:apply-templates select="@value" mode="lx:value-of"/>
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
     @template lx.html:keywords
     Insert an SEO compliant META keyword node.
    -->
  <xsl:template match="head/lx.html:keywords">
    <xsl:variable name="content">
        <xsl:apply-templates select="node()"/>
    </xsl:variable>

    <meta name="keywords" content="{normalize-space($content)}"/>
    <xsl:value-of select="$LX_LF"/>
  </xsl:template>

</xsl:stylesheet>
