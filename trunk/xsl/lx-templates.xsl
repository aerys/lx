<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.aerys.in"
                version="1.0">

  <xsl:variable name="LX_QUOTE">'</xsl:variable>
  <xsl:variable name="LX_DQUOTE">&#34;</xsl:variable>
  <xsl:variable name="LX_LF"><xsl:text>
</xsl:text></xsl:variable>
  <xsl:variable name="LX_LT">&#60;</xsl:variable>
  <xsl:variable name="LX_GT">&#62;</xsl:variable>

  <xsl:variable name="LX_PREFIX">lx</xsl:variable>

  <xsl:template name="lx:iterate">
    <xsl:param name="collection"/>
    <xsl:param name="delimiter"/>
    <xsl:param name="prologue"/>
    <xsl:param name="mode"/>

    <xsl:if test="$collection">
      <xsl:value-of select="$prologue"/>
      <xsl:for-each select="$collection[position() != last()]">
	<xsl:apply-templates select="."/>
	<xsl:value-of select="$delimiter"/>
      </xsl:for-each>
      <xsl:apply-templates select="$collection[position() = last()]"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="lx:str_ucfirst">
    <xsl:param name="string"/>

    <xsl:variable name="str_end" select="substring($string, 2)"/>
    <xsl:variable name="char" select="substring($string, 1, 1)"/>
    <xsl:variable name="upper_char">
      <xsl:call-template name="lx:str_uppercase">
	<xsl:with-param name="string" select="$char"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:value-of select="concat($upper_char, $str_end)"/>
  </xsl:template>

  <xsl:template name="lx:str_uppercase">
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
