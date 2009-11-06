<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.aerys.in">

  <xsl:include href="lx-std.xsl"/>

  <xsl:output method="html"
	      omit-xml-declaration="yes"
	      doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
	      doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
	      indent="yes"
	      encoding="utf-8"/>

  <xsl:template match="@* | node()">
    <xsl:apply-templates select="@* | node()"/>
  </xsl:template>

  <xsl:template match="xsl:stylesheet">
    <xsl:variable name="doc" select="preceding-sibling::node()[not(self::text()[not(normalize-space())])][1][self::comment()]"/>
    <xsl:variable name="name" select="substring-before(substring-after($doc, '@stylesheet '), $LX_LF)"/>
    <xsl:variable name="description" select="normalize-space(substring-after($doc, $name))"/>

    <html>
      <head>
	<title>
	  <xsl:value-of select="$name"/>
	  <xsl:text> - XSLDoc</xsl:text>
	</title>
      </head>

      <body>

	<xsl:if test="$doc and contains($doc, '@stylesheet')">
	  <h1>
	    <xsl:value-of select="$name"/>
	  </h1>
	  <p>
	    <xsl:value-of disable-output-escaping="yes" select="$description"/>
	  </p>
	</xsl:if>

	<ul>
	  <xsl:apply-templates select="xsl:variable"/>
	</ul>

	<ul>
	  <xsl:apply-templates select="xsl:template" mode="table"/>
	</ul>

	<br />

	<xsl:apply-templates select="xsl:template"/>

      </body>
    </html>
  </xsl:template>

  <xsl:template match="xsl:variable">
    <xsl:variable name="doc" select="preceding-sibling::node()[not(self::text()[not(normalize-space())])][1][self::comment()]"/>

    <xsl:if test="$doc and contains($doc, '@const')">
      <li>
	<xsl:value-of select="@name"/>
	<xsl:text> : </xsl:text>
	<xsl:value-of disable-output-escaping="yes" select="substring-after($doc, '@const ')"/>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xsl:template" mode="table">
    <xsl:variable name="doc" select="preceding-sibling::node()[not(self::text()[not(normalize-space())])][1][self::comment()]"/>

    <xsl:if test="$doc and contains($doc, '@template')">
      <xsl:variable name="name" select="normalize-space(substring-before(substring-after($doc, '@template '), ' '))"/>
      <xsl:variable name="description" select="normalize-space(substring-after($doc, $name))"/>

      <li>
	<a href="#{$name}">
	  <xsl:value-of select="$name"/>
	</a>
	<p>
	  <xsl:value-of select="$description"/>
	</p>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xsl:template">
    <xsl:variable name="doc" select="preceding-sibling::node()[not(self::text()[not(normalize-space())])][1][self::comment()]"/>

    <xsl:if test="$doc and contains($doc, '@template')">
      <xsl:variable name="name" select="normalize-space(substring-before(substring-after($doc, '@template '), ' '))"/>
      <xsl:variable name="description" select="normalize-space(substring-after($doc, $name))"/>

      <a name="{$name}"/>
      <h2>
	<xsl:value-of select="$name"/>
	<xsl:text>(</xsl:text>
	<xsl:call-template name="lx:for-each">
	  <xsl:with-param name="delimiter" select="', '"/>
	  <xsl:with-param name="collection" select="xsl:param"/>
	</xsl:call-template>
	<xsl:text>)</xsl:text>
      </h2>

      <xsl:if test="@match">
	<em>Match: </em>
	<xsl:value-of select="@match"/>
      </xsl:if>

      <xsl:if test="$description">
	<h3>Description</h3>
	<p>
	  <xsl:value-of disable-output-escaping="yes" select="$description"/>
	</p>
      </xsl:if>

      <xsl:if test="xsl:param">
	<h3>Parameters</h3>
	<ul>
	  <xsl:apply-templates select="xsl:param" mode="details"/>
	</ul>
      </xsl:if>
      <br />

    </xsl:if>
  </xsl:template>

  <xsl:template match="xsl:param" mode="details">
    <xsl:variable name="doc" select="preceding-sibling::node()[not(self::text()[not(normalize-space())])][1][self::comment()]"/>

    <li>
      <xsl:choose>
	<xsl:when test="xsl:apply-templates[@mode='lx:value-of']">
	  <em>
	    <xsl:value-of select="@name"/>
	    <xsl:value-of select="concat(' [', xsl:apply-templates/@select, ']')"/>
	  </em>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="@name"/>
	  <xsl:if test="@select">
	    <xsl:value-of select="concat(' [', @select, ']')"/>
	  </xsl:if>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:if test="contains($doc, '@param')">
	<xsl:text> : </xsl:text>
	<xsl:value-of disable-output-escaping="yes" select="substring-after($doc, '@param ')"/>
      </xsl:if>
    </li>
  </xsl:template>

  <xsl:template match="xsl:param">
    <xsl:value-of select="@name"/>
  </xsl:template>

</xsl:stylesheet>
