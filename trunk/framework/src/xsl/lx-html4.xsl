<?xml version="1.0" encoding="utf-8"?>

<?xml-stylesheet type="text/xsl" href="lx-xsldoc.xsl"?>

<!--
    @stylesheet LX HTML4
    HTML4 templates.
-->
<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.aerys.in">

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
	  <xsl:apply-templates select="$LX_LAYOUT/head/lx:title"/>
	  <xsl:apply-templates select="$LX_TEMPLATE/head/lx:title"/>
	</title>

	<xsl:apply-templates select="$LX_LAYOUT/head/*[name() != 'lx:title']"/>
	<xsl:apply-templates select="$LX_TEMPLATE/head/*[name() != 'lx:title']"/>

      </head>
      <body>
	<xsl:copy-of select="$LX_LAYOUT/body/@* | $LX_TEMPLATE/body/@*"/>

	<xsl:apply-templates select="$LX_LAYOUT/body/node()"/>
      </body>
    </html>
  </xsl:template>

  <!-- BEGIN IDENTITY -->
  <xsl:template match="*">
    <xsl:if test="not(ancestor::lx:response) and local-name()=name()">
      <xsl:element name="{name()}">
	<xsl:apply-templates select="@*|node()"/>
      </xsl:element>
    </xsl:if>
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
      @template lx:controller
      Default controller template.
    -->
  <xsl:template match="lx:controller">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <!--
      @template lx:title
      Set/concatenate the <title> value of the HTML document.
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
      @template lx:skin
    -->
  <xsl:template match="lx:skin"
		name="lx:skin">
    <xsl:apply-templates select="lx:css-stylesheet">
      <xsl:with-param name="skin">
	<xsl:apply-templates select="@name" mode="lx:value-of"/>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <!--
      @template lx:css-stylesheet
      Include a CSS stylesheet.
    -->
  <xsl:template name="lx:css-stylesheet"
		match="lx:css-stylesheet">
    <!-- @param name of the CSS stylesheet -->
    <xsl:param name="name" select="@name"/>
    <!-- @param name of the skin -->
    <xsl:param name="skin">
      <xsl:apply-templates select="@skin" mode="lx:value-of"/>
    </xsl:param>

    <link rel="stylesheet" type="text/css" href="styles/{$skin}/{$name}.css"/>
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
    <xsl:param name="content" select="node()[name() != 'lx:argument']"/>

    <xsl:variable name="url">
      <xsl:if test="$module != ''">
	<xsl:value-of select="$module"/>
	<xsl:text>/</xsl:text>
      </xsl:if>
      <xsl:if test="$controller != ''">
	<xsl:value-of select="$controller"/>
	<xsl:text>/</xsl:text>
      </xsl:if>
      <xsl:if test="$action != ''">
	<xsl:value-of select="$action"/>
      </xsl:if>
      <xsl:call-template name="lx:for-each">
	<xsl:with-param name="begin" select="'/'"/>
	<xsl:with-param name="delimiter" select="'/'"/>
	<xsl:with-param name="collection" select="$arguments"/>
      </xsl:call-template>
    </xsl:variable>


    <xsl:variable name="content_value">
      <xsl:choose>
	<xsl:when test="$content = node()">
	  <xsl:apply-templates select="$content"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$content"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <a href="{$url}">
      <xsl:value-of select="normalize-space($content_value)"/>
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
	<xsl:apply-templates select="$LX_TEMPLATE/body/node()"/>
      </xsl:otherwise>
    </xsl:choose>
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
    <!-- @param ressource name (without 'flash/' and '.swf') of the SWF file -->
    <xsl:param name="name" select="@name"/>
    <!-- @param javascript code to execute when the application is ready -->
    <xsl:param name="script" select="node()"/>
    <!-- @param width of the application -->
    <xsl:param name="width" select="@width"/>
    <!-- @param height of the application -->
    <xsl:param name="height" select="@height"/>
    <!-- @param flashvars -->
    <xsl:param name="flashvars" select="@flashvars"/>
    <!-- @param [opaque] wmode -->
    <xsl:param name="wmode">
      <xsl:value-of select="@wmode"/>
      <xsl:if test="@wmode = ''">
	<xsl:text>opaque</xsl:text>
      </xsl:if>
    </xsl:param>
    <!-- @param id -->
    <xsl:param name="id">
      <xsl:choose>
	<xsl:when test="@id">
	  <xsl:value-of select="@id"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="concat('flash_', generate-id())"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:param>

    <xsl:variable name="swf">
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
      <xsl:value-of select="$flashvars"/>
    </xsl:variable>

    <span id="{$id}">
      <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
	      id="{$name}" width="{$width}" height="{$height}"
	      codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">
	<param name="movie" value="{$swf}.swf" />
	<param name="quality" value="high" />
	<param name="allowScriptAccess" value="sameDomain" />
	<param name="flashvars" value="{$flashvars_full}" />
	<param name="wmode" value="{$wmode}" />
	<param name="name" value="{$id}"/>
	<embed src="{$swf}.swf"
	       width="{$width}" height="{$height}" name="{$id}" align="middle"
	       play="true"
	       loop="false"
	       flashvars="{$flashvars_full}"
	       quality="high"
	       allowScriptAccess="sameDomain"
	       type="application/x-shockwave-flash"
	       pluginspage="http://www.adobe.com/go/getflashplayer"
               wmode="{$wmode}">
	</embed>
      </object>

    <xsl:call-template name="lx:javascript">
      <xsl:with-param name="script">
        <xsl:text>var app=new FlashApplication(</xsl:text>
        <xsl:value-of select="concat($LX_DQUOTE, $swf, $LX_DQUOTE)"/>
        <xsl:text>,</xsl:text>
        <xsl:value-of select="concat($LX_DQUOTE, $id, $LX_DQUOTE)"/>
        <xsl:text>);</xsl:text>

        <xsl:if test="$script">
          <xsl:text>app.useFABridge=true;</xsl:text>
          <xsl:text>app.addEventListener(Event.COMPLETE,function(e){</xsl:text>
          <xsl:apply-templates select="$script"/>
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
