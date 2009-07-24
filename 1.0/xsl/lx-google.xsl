<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.aerys.in">

  <xsl:template match="lx:google-analytics">
    <xsl:variable name="script">
      new GoogleAnalytics('<xsl:value-of select="@code"/>').trackPageView();
    </xsl:variable>

    <!-- Function.js -->
    <xsl:call-template name="lx:javascript-class">
      <xsl:with-param name="name" select="'Function'"/>
    </xsl:call-template>

    <!-- GoogleAnalytics.js -->
    <xsl:call-template name="lx:javascript-class">
      <xsl:with-param name="name" select="'GoogleAnalytics'"/>
    </xsl:call-template>

    <xsl:call-template name="lx:javascript">
      <xsl:with-param name="script" select="$script"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>

