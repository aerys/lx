<?xml version="1.0" encoding="utf-8"?>

<?xml-stylesheet type="text/xsl" href="lx-xsldoc.xsl"?>

<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.aerys.in"
		xmlns:lx.flash="http://lx.aerys.in/flash"
                exclude-result-prefixes="lx.flash">

  <!--
      @template lx.flash:flash
      Insert Flash content.
    -->
  <xsl:template match="lx.flash:flash"
                name="lx.flash:flash">
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
    <xsl:param name="flashvars" select="lx.flash:flashvar"/>
    <!-- @param wmode -->
    <xsl:param name="wmode">
      <xsl:choose>
	<xsl:when test="@wmode!=''">
	  <xsl:value-of select="@wmode"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>window</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <!-- @param chache-killer -->
    <xsl:param name="cacheKiller" select="@cache-killer"/>
    <!-- @param alternative content -->
    <xsl:param name="alternativeContent" select="lx.flash:alternative-content"/>

    <xsl:variable name="swf">
      <xsl:text>flash/</xsl:text>
      <xsl:value-of select="$name"/>
      <xsl:if test="cacheKiller = 'true'">
        <xsl:text>?</xsl:text>
        <xsl:value-of select="$LX_RESPONSE/@time"/>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="flashvars_full">
      <xsl:if test="normalize-space($script)">
	<xsl:text>bridgeName=</xsl:text>
	<xsl:value-of select="$id"/>
	<xsl:if test="$flashvars">
	  <xsl:text>&amp;</xsl:text>
	</xsl:if>
      </xsl:if>
      <xsl:call-template name="lx:for-each">
        <xsl:with-param name="collection" select="$flashvars"/>
        <xsl:with-param name="delimiter" select="$LX_AMP"/>
      </xsl:call-template>
    </xsl:variable>

    <object type="application/x-shockwave-flash" data="{$swf}.swf" width="{$width}" height="{$height}"
	    style="outline:none;display:block">
      <xsl:if test="$id">
	<xsl:attribute name="id">
	  <xsl:value-of select="$id"/>
	</xsl:attribute>
      </xsl:if>
      <param name="movie" value="{$swf}.swf" />
      <param name="allowScriptAccess" value="sameDomain" />
      <param name="allowFullscreen" value="true" />
      <param name="flashvars" value="{$flashvars_full}" />
      <param name="wmode" value="{$wmode}" />
      <param name="name" value="{$name}"/>

      <xsl:apply-templates select="$alternativeContent"/>
    </object>
    <xsl:apply-templates select="lx.flash:fabridge"/>
  </xsl:template>

  <xsl:template match="lx.flash:alternative-content">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="lx.flash:fabridge">
    <!-- FIXME -->
  </xsl:template>

  <!--
      @template lx.flash:flashvar
    -->
  <xsl:template match="lx.flash:flashvar"
                name="lx.flash:flashvar">
    <xsl:variable name="value">
      <xsl:apply-templates select="@value" mode="lx:value-of"/>
    </xsl:variable>

    <xsl:if test="preceding-sibling::lx.flash:flashvar">
      <xsl:value-of select="$LX_AMP"/>
    </xsl:if>
    <xsl:value-of select="concat(@name, '=', $value)"/>
  </xsl:template>

  <!--
      lx.flash:fabridge
      Set a Flex-Ajax bridge using the FABridge library provided with the Flex SDK.
      The content of this markup must be JavaScript code. The Flex application is
      accessible using an object named by the id attribute specified in the parent
      lx.flash:flash node.
    -->
  <xsl:template match="lx.flash:fabridge">
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

    <script>
      <xsl:value-of select="normalize-space($callback)"/>
    </script>
  </xsl:template>

</xsl:stylesheet>
