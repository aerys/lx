<?xml version="1.0" encoding="utf-8"?>
<!--<?xml-stylesheet type="text/xsl" href="lx-doc.xsl"?>-->

<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.promethe.net"
		id="LX Standard Library">

  <xsl:variable name="LX_QUOTE">'</xsl:variable>
  <xsl:variable name="LX_DQUOTE">&#34;</xsl:variable>
  <xsl:variable name="LX_LF">&#10;</xsl:variable>
  <xsl:variable name="LX_LT">&#60;</xsl:variable>
  <xsl:variable name="LX_GT">&#62;</xsl:variable>

  <xsl:param name="LX_RESPONSE" select="/lx:response"/>
  <xsl:param name="LX_MEDIA" select="/lx:response/@media"/>

  <xsl:param name="LX_LAYOUT_NAME" select="/lx:response/@layout"/>
  <xsl:param name="LX_LAYOUT_FILE" select="concat($LX_MEDIA, '/layouts/', $LX_LAYOUT_NAME, '.xml')"/>
  <xsl:param name="LX_LAYOUT" select="document($LX_LAYOUT_FILE)/lx:layout"/>

  <xsl:param name="LX_CONTROLLER" select="/lx:response/lx:controller"/>

  <xsl:param name="LX_VIEW_NAME" select="/lx:response/@view"/>
  <xsl:param name="LX_VIEW_FILE" select="concat($LX_MEDIA, '/templates/', $LX_VIEW_NAME, '.xml')"/>
  <xsl:param name="LX_VIEW" select="document($LX_VIEW_FILE)/lx:view"/>

  <xsl:variable name="LX_FILTERS" select="$LX_RESPONSE/lx:filter"/>

  <!--
      @template lx:foreach
      An extension of the xsl:foreach function.
    -->
  <xsl:template name="lx:foreach">
    <!-- @param a string that will be printed before the collection -->
    <xsl:param name="begin" select="@begin"/>
    <!-- @param a string that will be printed between each element of the collection -->
    <xsl:param name="delimiter" select="@delimiter"/>
    <!-- @param the input collection to iterate on -->
    <xsl:param name="collection" select="."/>
    <!-- @param a string that will be printed after the collection -->
    <xsl:param name="end" select="@end"/>

    <xsl:variable name="count" select="count($collection)"/>
    <xsl:variable name="subset" select="$collection[position()!=$count]"/>
    <xsl:variable name="last" select="$collection[$count]"/>

    <xsl:if test="$collection">
      <xsl:value-of select="$begin"/>

      <xsl:for-each select="$subset">
	<xsl:apply-templates select="."/>
	<xsl:value-of select="$delimiter"/>
      </xsl:for-each>

      <xsl:apply-templates select="$last"/>

      <xsl:value-of select="$end"/>
    </xsl:if>
  </xsl:template>

  <!--
      @template lx:nl2br
      Translate every \n into <br /> tags.
    -->
  <xsl:template name="lx:nl2br">
    <!-- @param the inuput string -->
    <xsl:param name="string"/>

    <xsl:choose>
      <xsl:when test="contains($string, '&#10;')">
	<xsl:value-of select="substring-before($string, '&#10;')" disable-output-escaping="yes"/>
	<br/>
	<xsl:call-template name="lx:nl2br">
	  <xsl:with-param name="string" select="substring-after($string, '&#10;')"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$string" disable-output-escaping="yes"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
      @template lx:ucfirst
      Capitalize the first letter of a string.
    -->
  <xsl:template name="lx:ucfirst">
    <!-- @param the input string -->
    <xsl:param name="string"/>

    <xsl:variable name="str_end" select="substring($string, 2)"/>
    <xsl:variable name="char" select="substring($string, 1, 1)"/>
    <xsl:variable name="upper_char">
      <xsl:call-template name="lx:strtoupper">
	<xsl:with-param name="string" select="$char"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:value-of select="concat($upper_char, $str_end)"/>
  </xsl:template>

  <!--
      @template lx:strtoupper
      Converts all alphabetic characters to uppercase.
    -->
  <xsl:template name="lx:strtoupper">
    <!-- @param the input string -->
    <xsl:param name="string"/>

    <xsl:variable name="lower" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="upper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>

    <xsl:value-of select="translate($string, $lower, $upper)"/>
  </xsl:template>

  <xsl:template name="lx:str_lowercase">
    <xsl:param name="string"/>

    <xsl:variable name="lower" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="upper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>

    <xsl:value-of select="translate($string, $upper, $lower)"/>
  </xsl:template>

</xsl:stylesheet>
