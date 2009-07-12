<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.aerys.in"
		id="LX XML Response Utilities">

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

</xsl:stylesheet>
