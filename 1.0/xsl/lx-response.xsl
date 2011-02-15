<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.aerys.in"
		id="LX XML Response Utilities">

  <xsl:param name="LX_RESPONSE" select="/lx:response"/>
  <xsl:param name="LX_VIEW" select="$LX_RESPONSE/@view"/>

  <xsl:param name="LX_LAYOUT_NAME" select="$LX_RESPONSE/@layout"/>
  <xsl:param name="LX_LAYOUT_FILE" select="concat($LX_VIEW, '/layouts/', $LX_LAYOUT_NAME, '.xml')"/>
  <xsl:param name="LX_LAYOUT" select="document($LX_LAYOUT_FILE)/lx:layout"/>

  <xsl:param name="LX_CONTROLLER" select="$LX_RESPONSE/lx:controller"/>

  <xsl:param name="LX_TEMPLATE_NAME" select="$LX_RESPONSE/@template"/>
  <xsl:param name="LX_TEMPLATE_FILE" select="concat($LX_VIEW, '/templates/', $LX_TEMPLATE_NAME, '.xml')"/>
  <xsl:param name="LX_TEMPLATE" select="document($LX_TEMPLATE_FILE)/lx:template"/>

  <xsl:variable name="LX_FILTERS" select="$LX_RESPONSE/lx:filter"/>

</xsl:stylesheet>
