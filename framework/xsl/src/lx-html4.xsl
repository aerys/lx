<?xml version="1.0" encoding="utf-8"?>

<?xml-stylesheet type="text/xsl" href="lx-xsldoc.xsl"?>

<!--
    @stylesheet LX HTML4
    HTML4 templates.
-->
<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.aerys.in"
		xmlns:lx.html="http://lx.aerys.in/html"
        exclude-result-prefixes="lx.html">

  <xsl:output method="html"
	      version="4.0"
	      omit-xml-declaration="yes"
	      doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"
	      doctype-system="http://www.w3.org/TR/html4/loose.dtd"
	      indent="yes"
	      encoding="unicode"/>

  <xsl:template match="/">
    <html>
      <head>

        <title>
	  <xsl:apply-templates select="$LX_LAYOUT/lx:layout/head/title/node()"/>
	  <xsl:apply-templates select="$LX_TEMPLATE/lx:template/head/title/node()"/>
	</title>

	<meta http-equiv="Content-Type" content="text/html;charset=UTF-8"/>

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
	
        <!-- Client XSL support detection -->
        <xsl:call-template name="lx.html:detect-client-xsl-support"/>

        <xsl:apply-templates select="$LX_LAYOUT/lx:layout/head/*[name()!='title']"/>
	<xsl:apply-templates select="$LX_TEMPLATE/lx:template/head/*[name()!='title']"/>

      </head>
      <body>
	<xsl:copy-of select="$LX_LAYOUT/lx:layout/body/@* | $LX_TEMPLATE/lx:template/body/@*"/>
	<xsl:apply-templates select="$LX_LAYOUT/lx:layout/body/node()"/>
      </body>
    </html>
  </xsl:template>

<xsl:include href="lx-html-utils.xsl" />


</xsl:stylesheet>
