<?xml version="1.0" encoding="utf-8"?>

<?xml-stylesheet type="text/xsl" href="lx-xsldoc.xsl"?>

<!--
    @stylesheet LX XPath Evaluator
    Templates to evaluate XPath expressions and lx:value-of tags.
-->
<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.aerys.in"
		xmlns:lx.xpath="http://lx.aerys.in/xpath">

  <xsl:variable name="LX_XPATH_START">{</xsl:variable>
  <xsl:variable name="LX_XPATH_STOP">}</xsl:variable>
  <xsl:variable name="LX_XPATH_OPERATORS">/@[]!=</xsl:variable>

  <xsl:template match="@*">
    <xsl:variable name="xpath" select="substring-after(substring-before(., $LX_XPATH_STOP), $LX_XPATH_START)"/>

    <xsl:attribute name="{name()}">
      <xsl:choose>
	<xsl:when test="$xpath != ''">
	  <xsl:call-template name="lx.xpath:parse-expression">
	    <xsl:with-param name="expression" select="$xpath"/>
	  </xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="."/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@*" mode="lx:value-of">
    <xsl:variable name="xpath" select="substring-after(substring-before(., $LX_XPATH_STOP), $LX_XPATH_START)"/>

    <xsl:choose>
      <xsl:when test="$xpath != ''">
	<xsl:call-template name="lx.xpath:parse-expression">
	  <xsl:with-param name="expression" select="$xpath"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
      @template lx:value-of
      Insert data from the XML Response (lx:response) using XPath <b>expressions</b>.
    -->
  <xsl:template match="lx:value-of"
		name="lx:value-of">
    <!-- @param The XPath expression to evaluate. -->
    <xsl:param name="xpath" select="@select"/>

    <xsl:call-template name="lx.xpath:parse-expression">
      <xsl:with-param name="expression" select="$xpath"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="lx.xpath:parse-expression">
    <!-- @param The XPath expression to evaluate. -->
    <xsl:param name="expression"/>
    <!-- @param The root node (/) to use. -->
    <xsl:param name="root" select="$LX_RESPONSE"/>

   <xsl:variable name="operator">
      <xsl:call-template name="lx.xpath:get-operator">
	<xsl:with-param name="expression" select="$expression"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="node">
      <xsl:call-template name="lx.xpath:get-node">
	<xsl:with-param name="expression" select="substring-after($expression, $operator)"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="new_path" select="substring-after(substring-after($expression, $operator), $node)"/>

    <xsl:choose>
      <xsl:when test="$operator = '//'">
	<xsl:call-template name="lx.xpath:parse-expression">
	  <xsl:with-param name="expression" select="$new_path"/>
	  <xsl:with-param name="root" select="$root//node()[name()=$node]"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="$operator = '@' or $operator = '/@' or $operator = '//@'">
	<xsl:call-template name="lx.xpath:parse-expression">
	  <xsl:with-param name="expression" select="$new_path"/>
	  <xsl:with-param name="root" select="$root/@*[$node='*']|$root/@*[name()=$node]"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="$operator = '/' or ($operator = '' and $node != '')">
	<xsl:call-template name="lx.xpath:parse-expression">
	  <xsl:with-param name="expression" select="$new_path"/>
	  <xsl:with-param name="root" select="$root/node()[$node='*']|$root/node()[name()=$node]"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="$operator = '['">
	<xsl:call-template name="lx.xpath:parse-expression">
	  <xsl:with-param name="expression" select="substring-after($new_path, ']')"/>
	  <xsl:with-param name="root" select="$root[position()=$node]"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$root"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="lx.xpath:get-node">
    <xsl:param name="expression"/>

    <xsl:variable name="char" select="substring($expression, 1, 1)"/>

    <xsl:if test="string-length($expression) and not(contains($LX_XPATH_OPERATORS, $char))">
      <xsl:if test="$char != ' '">
	<xsl:value-of select="$char"/>
      </xsl:if>

      <xsl:call-template name="lx.xpath:get-node">
	<xsl:with-param name="expression" select="substring($expression, 2)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="lx.xpath:get-operator">
    <xsl:param name="expression"/>

    <xsl:variable name="char" select="substring($expression, 1, 1)"/>

    <xsl:choose>
      <xsl:when test="$char = ' '">
	<xsl:call-template name="lx.xpath:get-operator">
	  <xsl:with-param name="expression" select="normalize-space($expression)"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="$char != '' and contains($LX_XPATH_OPERATORS, $char)">
	<xsl:value-of select="$char"/>

	<xsl:if test="$char = '/' or $char = '!'">
	  <xsl:call-template name="lx.xpath:get-operator">
	    <xsl:with-param name="expression" select="substring($expression, 2)"/>
	  </xsl:call-template>
	</xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
