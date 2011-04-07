<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.aerys.in">

  <xsl:output ommit-xml-declaration="no"
              output="xml"
	      encoding="utf-8"/>

  <xsl:include href="../lx-std.xsl"/>

  <xsl:variable name="LX_PROJECT_ROOT_NODE" select="/"/>

  <xsl:template match="/">
    <xsl:element name="xsl:stylesheet">
      <xsl:attribute name="version">1.0</xsl:attribute>
      <xsl:apply-templates select="lx:project"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="lx:project">
    <xsl:apply-templates select="lx:const"/>
    <xsl:apply-templates select="lx:database"/>
  </xsl:template>

  <xsl:template match="lx:const[@name][@value]">
    <xsl:call-template name="lx:xsl_var">
      <xsl:with-param name="name" select="@name"/>
      <xsl:with-param name="value" select="@value"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="lx:database">
    <xsl:for-each select="@*">
      <xsl:call-template name="lx:xsl_var">
        <xsl:with-param name="name" select="concat('db_', name())"/>
        <xsl:with-param name="value" select="'current()'"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="lx:xsl_var">
    <xsl:param name="name"/>
    <xsl:param name="value"/>

    <xsl:element name="xsl:variable">
      <xsl:attribute name="name">
      	<xsl:call-template name="lx:strtoupper">
          <xsl:with-param name="string" select="$name"/>
        </xsl:call-template>
      </xsl:attribute>

      <xsl:attribute name="select">
        <xsl:value-of select="$value"/>
      </xsl:attribute>
    </xsl:element>

  </xsl:template>

</xsl:stylesheet>
