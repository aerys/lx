<?xml version="1.0" encoding="utf-8"?>

<?xml-stylesheet type="text/xsl" href="lx-xsldoc.xsl"?>

<!--
    @stylesheet LX Response
    Constants definitions.
-->
<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.aerys.in">

  <!-- @const response root node (/lx:response) -->
  <xsl:variable name="LX_RESPONSE" select="/lx:response"/>

  <!-- @const request node (/lx:response/lx:request) -->
  <xsl:variable name="LX_REQUEST" select="/lx:response/lx:request"/>

  <!-- @const response view node (lx:view) -->
  <xsl:variable name="LX_VIEW" select="$LX_RESPONSE/lx:view"/>
  <!-- @const view name -->
  <xsl:variable name="LX_VIEW_NAME" select="$LX_VIEW/@name"/>

  <!-- @const layout name -->
  <xsl:variable name="LX_LAYOUT_NAME" select="$LX_VIEW/@layout"/>
  <!-- @const layout filename URI -->
  <xsl:variable name="LX_LAYOUT_FILE" select="concat($LX_VIEW_NAME, '/layouts/', $LX_LAYOUT_NAME, '.xml')"/>
  <!-- @const layout document root node -->
  <xsl:variable name="LX_LAYOUT" select="document($LX_LAYOUT_FILE)"/>

  <!-- @const template name -->
  <xsl:variable name="LX_TEMPLATE_NAME" select="$LX_VIEW/@template"/>
  <!-- @const template filename URI -->
  <xsl:variable name="LX_TEMPLATE_FILE" select="concat($LX_VIEW_NAME, '/templates/', $LX_TEMPLATE_NAME, '.xml')"/>
  <!-- @const template document root node -->
  <xsl:variable name="LX_TEMPLATE" select="document($LX_TEMPLATE_FILE)"/>

  <!-- @const filter nodes (lx:filter) -->
  <xsl:variable name="LX_FILTERS" select="$LX_RESPONSE/lx:filters"/>

  <!-- @const controller node (lx:controller) -->
  <xsl:variable name="LX_CONTROLLER" select="$LX_RESPONSE/lx:controller"/>

  <!--
      @template lx:insert-template
      Set where to insert the view template.
      If an lx:exception node is available, it is matchd instead of the template.
    -->
  <xsl:template match="lx:insert-template">
    <xsl:choose>
      <xsl:when test="$LX_RESPONSE/lx:error">
	<xsl:apply-templates select="$LX_RESPONSE/lx:error"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates select="$LX_TEMPLATE/lx:template"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- BEGIN IDENTITY -->
  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|processing-instruction()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="comment()">
    <xsl:if test="$LX_RESPONSE/@debug = 'true'">
      <xsl:copy>
        <xsl:apply-templates select="node()"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:if test="normalize-space(.) != '' or not(following-sibling::lx:text or preceding-sibling::lx:text)">
      <xsl:copy>
	<xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  <!-- END IDENTITY -->

  <xsl:template match="lx:controller|lx:layout">
    <xsl:value-of select="name()"/>
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="lx:template">
    <xsl:choose>
      <xsl:when select="$LX_RESPONSE//lx:exception">
        <xsl:apply-templates select="$LX_RESPONSE//lx:exception"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="node()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
