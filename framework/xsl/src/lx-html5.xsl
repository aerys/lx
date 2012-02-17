<?xml version="1.0" encoding="utf-8"?>

<?xml-stylesheet type="text/xsl" href="lx-xsldoc.xsl"?>

<!--
    @stylesheet LX HTML5
    HTML5 templates.
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:lx="http://lx.aerys.in"
                xmlns:lx.html="http://lx.aerys.in/html"
                exclude-result-prefixes="lx.html">

  <xsl:output method="html"
              encoding='utf-8'
              omit-xml-declaration="yes"
              indent="yes"/>

  <xsl:include href="lx-html-common.xsl" />

  <xsl:variable name="LX_HTML_HEAD" select="$LX_LAYOUT/lx:layout/head
                                            | $LX_TEMPLATE/lx:template/head"/>
  <xsl:variable name="LX_HTML_BODY" select="$LX_LAYOUT/lx:layout/body
                                            | $LX_TEMPLATE/lx:template/body"/>

  <xsl:template match="/">
    <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;&#10;</xsl:text>
    <html>
      <head>

        <title>
          <xsl:apply-templates select="$LX_HTML_HEAD/title/node()"/>
        </title>

        <!-- Both are useful for browser compatibility. -->
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta charset="utf-8" />

        <base>
          <xsl:attribute name="href">
            <xsl:text>http://</xsl:text>
            <xsl:value-of select="$LX_RESPONSE/@host"/>
            <xsl:if test="$LX_RESPONSE/@documentRoot != '/'">
              <xsl:value-of select="$LX_RESPONSE/@documentRoot"/>
            </xsl:if>
            <xsl:text>/</xsl:text>
          </xsl:attribute>
        </base>

        <!-- CSS -->
        <xsl:apply-templates select="$LX_HTML_HEAD/*
                                     [descendant-or-self::lx.html:stylesheet]"/>

        <!-- JavaScript -->
        <xsl:apply-templates select="$LX_HTML_HEAD/*
                                     [descendant-or-self::lx.html:javascript]
                                     [. = '']"/>
        <xsl:apply-templates select="$LX_HTML_HEAD/*
                                     [descendant-or-self::lx.html:javascript]
                                     [. != '']"/>

        <xsl:apply-templates select="$LX_HTML_HEAD/*
                                     [name()!='title']
                                     [not(descendant-or-self::lx.html:stylesheet)]
                                     [not(descendant-or-self::lx.html:javascript)]"/>
      </head>
      <body>
        <xsl:copy-of select="$LX_LAYOUT/lx:layout/body/@* | $LX_TEMPLATE/lx:template/body/@*"/>
        <xsl:apply-templates select="$LX_LAYOUT/lx:layout/body/node()"/>

        <!-- Client XSL support detection -->
        <xsl:call-template name="lx.html:detect-client-xsl-support"/>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
