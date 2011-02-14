<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.aerys.in">

  <xsl:variable name="CSV_SEPARATOR">;</xsl:variable>

  <xsl:template match="/">
    <!--<xsl:apply-templates select="$LX_TEMPLATE/*"/>-->
    <xsl:apply-templates select="//lx:controller"/>
  </xsl:template>

  <xsl:template match="lx:controller">
    <xsl:call-template name="csv-columns">
      <xsl:with-param name="node" select="node()[1]"/>
    </xsl:call-template>
    <xsl:for-each select="node()">
      <xsl:value-of select="$LX_LF"/>
      <xsl:for-each select="node()">
	<xsl:if test="position() != 1">
	  <xsl:value-of select="$CSV_SEPARATOR"/>
	</xsl:if>
	<xsl:value-of select="$LX_DQUOTE"/>
	<xsl:apply-templates select="."/>
	<xsl:value-of select="$LX_DQUOTE"/>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:call-template name="csv-escape-string"/>
  </xsl:template>

  <xsl:template match="node()">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template name="csv-columns">
    <xsl:param name="node" select="."/>

    <xsl:for-each select="$node/node()">
      <xsl:if test="position() != 1">
	<xsl:value-of select="$CSV_SEPARATOR"/>
      </xsl:if>
      <xsl:value-of select="$LX_DQUOTE"/>
      <xsl:value-of select="name()"/>
      <xsl:value-of select="$LX_DQUOTE"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="csv-escape-string">
    <!-- @param the input string -->
    <xsl:param name="string" select="."/>

    <xsl:choose>
      <xsl:when test="contains($string, $LX_DQUOTE)">
	<xsl:value-of select="substring-before($string, $LX_DQUOTE)"
                      disable-output-escaping="yes"/>
	<xsl:value-of select="$LX_DQUOTE"/>
	<xsl:value-of select="$LX_DQUOTE"/>
	<xsl:call-template name="csv-escape-string">
	  <xsl:with-param name="string" select="substring-after($string, $LX_DQUOTE)"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$string" disable-output-escaping="yes"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
