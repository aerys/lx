<?xml version="1.0" encoding="utf-8"?>
<?xml-stylesheet type="text/xsl" href="/views/lx-doc.xsl"?>

<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.aerys.in"
		id="LX XHTML Library">

  <xsl:output method="html"
	      omit-xml-declaration="yes"
	      doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
	      doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
	      indent="yes"
	      encoding="unicode"/>

  <xsl:include href="lx-std.xsl"/>
  <xsl:include href="lx-response.xsl"/>

  <xsl:template match="/">
    <html>
      <head>
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
	  <xsl:apply-templates select="$LX_LAYOUT/head/lx:title | $LX_VIEW/head/lx:title"/>
	</title>

	<xsl:apply-templates select="$LX_LAYOUT/head/*[name() != 'lx:title']"/>
	<xsl:apply-templates select="$LX_VIEW/head/*[name() != 'lx:title']"/>

      </head>
      <body>
	<xsl:copy-of select="$LX_LAYOUT/body/@* | $LX_VIEW/body/@*"/>

	<xsl:apply-templates select="$LX_LAYOUT/body/node()"/>
      </body>
    </html>
  </xsl:template>

  <!-- BEGIN IDENTITY -->
  <xsl:template match="*">
    <xsl:if test="not(ancestor::lx:response)">
      <xsl:element name="{name()}">
	<xsl:apply-templates select="@*|node()"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@*|text()|comment()|processing-instruction()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  <!-- END IDENTITY -->

  <!--
      @template lx:controller
      Default controller pattern.
    -->
  <xsl:template match="lx:controller">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <!--
      @template lx:title
      Set/concatenate the <title> value.
    -->
  <xsl:template match="lx:title"
		name="lx:title">
    <!-- @param the title to set/concatenate -->
    <xsl:param name="content" select="node()"/>

    <xsl:apply-templates select="$content" />
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
      @template lx:javascript-class
      Include a javascript class.
    -->
  <xsl:template name="lx:javascript-class"
		match="lx:javascript-class">
    <!-- @param name of the javascript class -->
    <xsl:param name="name" select="@name"/>

    <script language="javascript" type="text/javascript"
	    src="javascript/class/{$name}.js"></script>
    <xsl:value-of select="$LX_LF"/>
  </xsl:template>

  <!--
      @template lx:javascript-library
      Include a javascript library.
    -->
  <xsl:template name="lx:javascript-library"
		match="lx:javascript-library">
    <!-- @param name of the javascript library -->
    <xsl:param name="name" select="@name"/>

    <script language="javascript" type="text/javascript"
	    src="javascript/libs/{$name}.js"></script>
    <xsl:value-of select="$LX_LF"/>
  </xsl:template>

  <!--
      @template lx:javascript
      Embed javascript code.
    -->
  <xsl:template name="lx:javascript"
		match="lx:javascript">
    <!-- @param javascript code to embed -->
    <xsl:param name="script" select="."/>

    <script language="javascript" type="text/javascript">
      <xsl:value-of select="$script"/>
    </script>
    <xsl:value-of select="$LX_LF"/>
  </xsl:template>

  <!--
      @template lx:css-stylesheet
      Include a CSS stylesheet.
    -->
  <xsl:template name="lx:css-stylesheet"
		match="lx:css-stylesheet">
    <!-- @param name of the CSS stylesheet -->
    <xsl:param name="name" select="@name"/>

    <link rel="stylesheet" type="text/css" href="styles/default/{$name}.css"/>
    <xsl:value-of select="$LX_LF"/>
  </xsl:template>

  <!--
      @template lx:css
      Include a CSS style declaration
    -->
  <xsl:template name="lx:css"
		match="lx:css">
    <!-- @param style declaration -->
    <xsl:param name="style" select="text()"/>

    <style type="text/css">
      <xsl:copy-of select="$style"/>
    </style>
  </xsl:template>

  <!--
      @template lx:link-controller
      Create a link to a controller.
    -->
  <xsl:template match="lx:link[@controller] | lx:link[@module]"
		name="lx:link-controller">
    <!-- @param module name -->
    <xsl:param name="module" select="@module"/>
    <!-- @param controller name -->
    <xsl:param name="controller" select="@controller"/>
    <!-- @param action to call -->
    <xsl:param name="action" select="@action"/>
    <!-- @param action arguments -->
    <xsl:param name="arguments" select="lx:argument"/>
    <!-- @param content of the link (string | node)-->
    <xsl:param name="content" select="node()[name() != 'lx:argument']"/>

    <xsl:variable name="url">
      <xsl:if test="$module">
	<xsl:value-of select="$module"/>
	<xsl:if test="$controller">
	  <xsl:text>/</xsl:text>
	</xsl:if>
      </xsl:if>
      <xsl:if test="$controller">
	<xsl:value-of select="$controller"/>
      </xsl:if>
      <xsl:if test="$action">
	<xsl:text>/</xsl:text>
	<xsl:value-of select="$action"/>
      </xsl:if>
      <xsl:call-template name="lx:foreach">
	<xsl:with-param name="begin" select="'/'"/>
	<xsl:with-param name="delimiter" select="'/'"/>
	<xsl:with-param name="collection" select="$arguments"/>
      </xsl:call-template>
    </xsl:variable>

    <a href="{$url}">
      <xsl:choose>
	<xsl:when test="$content = string($content)">
	  <xsl:value-of select="$content"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:apply-templates select="$content"/>
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
      @template lx:link
      Create a link.
    -->
  <xsl:template match="lx:link[@href]"
		name="lx:link">
    <!-- @param URL of the link -->
    <xsl:param name="href" select="@href"/>
    <!-- @param content of the link -->
    <xsl:param name="content" select="node()"/>
    <!-- @param target of the link ('_blank' | '_parent') -->
    <xsl:param name="target">
      <xsl:choose>
	<xsl:when test="@target">
	  <xsl:value-of select="@target"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>_self</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:param>

    <a href="{$href}" target="{$target}">
      <xsl:choose>
	<xsl:when test="$content = node()">
	  <xsl:apply-templates select="node()"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$content"/>
	</xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:template>

  <!--
      @template lx:insert-view-here
      Set where to insert the view template.
      If an lx:exception node is available, it is matchd instead of the view.
    -->
  <xsl:template match="lx:insert-view-here">
    <xsl:choose>
      <xsl:when test="$LX_RESPONSE/lx:error">
	<xsl:apply-templates select="$LX_RESPONSE/lx:error"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates select="$LX_VIEW/body"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="lx:view/body">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <!--
      @template lx:insert-controller-here
      Set where to insert the view generated output.
    -->
  <xsl:template match="lx:insert-controller-here">
    <xsl:apply-templates select="$LX_CONTROLLER"/>
  </xsl:template>

  <!--
      @template lx:flash
      Insert Flash content.
      The content of the tag is used as javascript code and is automagicaly called when the Flash application is ready.
    -->
  <xsl:template match="lx:flash"
                name="lx:flash">
    <!-- @param ressource name (without '/flash/') of the SWF file -->
    <xsl:param name="name" select="@name"/>
    <!-- @param javascript code to execute when the application is ready -->
    <xsl:param name="script" select="text()"/>
    <!-- @param width of the application -->
    <xsl:param name="width" select="@width"/>
    <!-- @param height of the application -->
    <xsl:param name="height" select="@height"/>
    <!-- @param ommit the default .swf extension -->
    <xsl:param name="ommit-extension" select="@ommit-extension"/>
    <!-- @param flashvars -->
    <xsl:param name="flashvars" select="@flashvars"/>
    <!-- @param wmode -->
    <xsl:param name="wmode" select="@wmode"/>

    <xsl:variable name="id" select="concat('flash_', generate-id())"/>
    <xsl:variable name="url">
      <xsl:text>flash/</xsl:text>
      <xsl:value-of select="$name"/>
    </xsl:variable>

    <span id="{$id}">
    <xsl:call-template name="lx:javascript">
      <xsl:with-param name="script">
        <xsl:text>var app=new FlashApplication(</xsl:text>
        <xsl:value-of select="concat($LX_DQUOTE, $url, $LX_DQUOTE)"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="concat($LX_DQUOTE, $id, $LX_DQUOTE)"/>
        <xsl:text>);</xsl:text>

        <!-- BEGIN FLASHVARS -->
        <xsl:if test="$flashvars">
          <xsl:text>app.flashvars=</xsl:text>
          <xsl:value-of select="concat($LX_DQUOTE, $flashvars, $LX_DQUOTE, ';')"/>
        </xsl:if>
        <!-- END FLASHVARS -->

        <xsl:if test="$wmode">
          <xsl:text>app.wmode=</xsl:text>
          <xsl:value-of select="concat($LX_DQUOTE, $wmode, $LX_DQUOTE, ';')"/>
        </xsl:if>

        <xsl:if test="$ommit-extension = 'true'">
          <xsl:text>app.ommitExtension=true;</xsl:text>
        </xsl:if>

        <xsl:text>app.width=</xsl:text>
        <xsl:value-of select="concat($LX_DQUOTE, $width, $LX_DQUOTE, ';')"/>
        <xsl:text>app.height=</xsl:text>
        <xsl:value-of select="concat($LX_DQUOTE, $height, $LX_DQUOTE, ';')"/>
        <xsl:if test="$script">
          <xsl:text>app.useFABridge=true;</xsl:text>
          <xsl:text>app.addEventListener(Event.COMPLETE,function(e){</xsl:text>
          <xsl:value-of select="$script"/>
          <xsl:text>});</xsl:text>
        </xsl:if>
        <xsl:text>app.run(document.getElementById(</xsl:text>
        <xsl:value-of select="concat($LX_DQUOTE, $id, $LX_DQUOTE)"/>
        <xsl:text>));</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    </span>
  </xsl:template>

</xsl:stylesheet>
