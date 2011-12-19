<?xml version="1.0" encoding="utf-8"?>

<?xml-stylesheet type="text/xsl" href="lx-xsldoc.xsl"?>

<!--
    @stylesheet LX Standard Template Library
    This stylehsheet implements common and very useful templates to overload
    basic features of XSLT 1.0.
-->
<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.aerys.in"
		xmlns:lx.xpath="http://lx.aerys.in/xpath"
                exclude-result-prefixes="lx"
		id="LX Standard Library">

  <!-- XPath constants -->
  <xsl:variable name="LX_XPATH_START">{</xsl:variable>
  <xsl:variable name="LX_XPATH_STOP">}</xsl:variable>
  <xsl:variable name="LX_XPATH_OPERATORS">/@[]#</xsl:variable>

  <!-- @const quote (') character -->
  <xsl:variable name="LX_QUOTE">'</xsl:variable>
  <!-- @const double-quotes (") character -->
  <xsl:variable name="LX_DQUOTE">&#34;</xsl:variable>
  <!-- @const line feed (\n) character -->
  <xsl:variable name="LX_LF"><xsl:text>
</xsl:text></xsl:variable>
  <!-- @const space character -->
  <xsl:variable name="LX_NBSP">&#160;</xsl:variable>
  <!-- @const lesser-than (<) character -->
  <xsl:variable name="LX_LT">&#60;</xsl:variable>
  <!-- @const greater-then (>) character -->
  <xsl:variable name="LX_GT">&#62;</xsl:variable>
  <!-- @const amp character character -->
  <xsl:variable name="LX_AMP">&#38;</xsl:variable>

  <!--
      @template lx:for-each
      An extension of the xsl:for-each function.
    -->
  <xsl:template match="lx:for-each"
		name="lx:for-each">
    <!-- @param a string that will be printed before the collection -->
    <xsl:param name="begin"/>
    <!-- @param a string that will be printed between each element of the collection -->
    <xsl:param name="delimiter"/>
    <!-- @param the input collection to iterate on -->
    <xsl:param name="collection"/>
    <!-- @param a string that will be printed after the collection -->
    <xsl:param name="end"/>

    <xsl:variable name="count" select="count($collection)"/>
    <xsl:variable name="subset" select="$collection[position()!=$count]"/>
    <xsl:variable name="last" select="$collection[$count]"/>

    <xsl:if test="$collection">
      <xsl:value-of select="$begin"/>

      <xsl:for-each select="$subset">
	<xsl:apply-templates select="."/>
	<xsl:value-of select="$delimiter"/>
      </xsl:for-each>

      <xsl:apply-templates select="$last"/>

      <xsl:value-of select="$end"/>
    </xsl:if>
  </xsl:template>

  <!--
      @template lx:text
      See <xsl:text>.
    -->
  <xsl:template match="lx:text">
    <!-- @param the output text -->
    <xsl:param name="content">
      <xsl:apply-templates select="node()"/>
    </xsl:param>
    <!-- @param -->
    <xsl:param name="normalize" select="@normalize"/>

    <xsl:choose>
      <xsl:when test="$normalize='false'">
        <xsl:value-of select="$content"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space($content)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
      @template lx:nl2br
      Translate every \n into <br /> tags.
    -->
  <xsl:template name="lx:nl2br">
    <!-- @param the inuput string -->
    <xsl:param name="string"/>

    <xsl:choose>
      <xsl:when test="contains($string, '&#10;')">
	<xsl:value-of select="substring-before($string, '&#10;')" disable-output-escaping="yes"/>
	<br/>
	<xsl:call-template name="lx:nl2br">
	  <xsl:with-param name="string" select="substring-after($string, '&#10;')"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$string" disable-output-escaping="yes"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
      @template lx:ucfirst
      Capitalize the first letter of a string.
    -->
  <xsl:template name="lx:ucfirst">
    <!-- @param the input string -->
    <xsl:param name="string"/>

    <xsl:variable name="str_end" select="substring($string, 2)"/>
    <xsl:variable name="char" select="substring($string, 1, 1)"/>
    <xsl:variable name="upper_char">
      <xsl:call-template name="lx:strtoupper">
	<xsl:with-param name="string" select="$char"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:value-of select="concat($upper_char, $str_end)"/>
  </xsl:template>

  <!--
      @template lx:strtoupper
      Converts all alphabetic characters to uppercase.
    -->
  <xsl:template name="lx:strtoupper">
    <!-- @param the input string -->
    <xsl:param name="string"/>

    <xsl:variable name="lower" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="upper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>

    <xsl:value-of select="translate($string, $lower, $upper)"/>
  </xsl:template>

  <!--
      @template lx:strtoupper
      Converts all alphabetic characters to lowercase.
    -->
  <xsl:template name="lx:strlower">
    <!-- @param the input string -->
    <xsl:param name="string"/>

    <xsl:variable name="lower" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="upper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>

    <xsl:value-of select="translate($string, $upper, $lower)"/>
  </xsl:template>

  <!--
      @template lx:is_string
      Return true if the input string starts and ends with '.
    -->
  <xsl:template name="lx:is_string">
    <!-- @param the string to test -->
    <xsl:param name="string"/>

    <xsl:value-of select="starts-with($string, $LX_QUOTE) and not(substring-after($string, $LX_QUOTE))"/>
  </xsl:template>

  <!--
      @template lx:is_number
      Return true if the input object is a number.
    -->
  <xsl:template name="lx:is_number">
    <!-- @param the input object to test -->
    <xsl:param name="input"/>

    <xsl:value-of select="$input = number($input)"/>
  </xsl:template>

  <!--
      @template lx:is_integer
      Return true if the input object is an interger.
    -->
  <xsl:template name="lx:is_integer">
    <xsl:param name="input"/>

    <xsl:value-of select="ceiling(number($input)) = $input"/>
  </xsl:template>

  <!--
      @template lx:is_boolean
      Return true if the input object is a boolean.
    -->
  <xsl:template name="lx:is_boolean">
    <xsl:param name="input"/>

    <xsl:value-of select="$input = 'true' or $input = 'false'"/>
  </xsl:template>

  <xsl:template name="lx:typeof">
    <xsl:param name="input"/>

    <xsl:variable name="isInteger">
      <xsl:call-template name="lx:is_integer">
	<xsl:with-param name="input" select="$input"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="isBoolean">
      <xsl:call-template name="lx:is_boolean">
	<xsl:with-param name="input" select="$input"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$isInteger = 'true'">integer</xsl:when>
      <xsl:when test="$isBoolean = 'true'">boolean</xsl:when>
      <xsl:otherwise>string</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@*">
    <xsl:attribute name="{name()}">
      <xsl:apply-templates select="." mode="lx:value-of"/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="/lx:layout//@* | /lx:template//@*">
    <xsl:attribute name="{name()}">
      <xsl:apply-templates select="." mode="lx:value-of">
        <xsl:with-param name="root" select="/ | . | $LX_RESPONSE | $LX_TEMPLATE"/>
      </xsl:apply-templates>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@*" mode="lx:value-of"
		name="lx:value-of-attribute">
    <xsl:param name="value" select="."/>
    <xsl:param name="root" select="/ | .. | $LX_RESPONSE | $LX_TEMPLATE"/>

    <xsl:variable name="xpath"
		  select="substring-after(substring-before($value, $LX_XPATH_STOP), $LX_XPATH_START)"/>

    <xsl:choose>

      <xsl:when test="$xpath != ''">
	<xsl:value-of select="substring-before($value, $LX_XPATH_START)"/>

	<xsl:call-template name="lx.xpath:expression-to-value">
	  <xsl:with-param name="expression" select="$xpath"/>
          <xsl:with-param name="root" select="$root"/>
	</xsl:call-template>

	<xsl:call-template name="lx:value-of-attribute">
	  <xsl:with-param name="value" select="substring-after($value, $LX_XPATH_STOP)"/>
          <xsl:with-param name="root" select="$root"/>
	</xsl:call-template>
      </xsl:when>

      <xsl:otherwise>
	<xsl:value-of select="$value"/>
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

    <xsl:choose>
      <xsl:when test="/lx:layout or /lx:template">
        <xsl:call-template name="lx.xpath:expression-to-value">
          <xsl:with-param name="expression" select="$xpath"/>
          <xsl:with-param name="root" select="/ | $LX_RESPONSE"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="lx.xpath:expression-to-value">
          <xsl:with-param name="expression" select="$xpath"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="lx:if">
    <xsl:variable name="test">
      <xsl:call-template name="lx.xpath:expression-to-value">
        <xsl:with-param name="expression" select="@test"/>
        <xsl:with-param name="root" select="$LX_RESPONSE"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$test != ''">
        <xsl:apply-templates select="node()"/>
      </xsl:when>
      <xsl:when test="following-sibling::node() = following-sibling::lx:else[1]">
        <xsl:apply-templates select="following-sibling::lx:else[1]/node()"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="lx:else">
    <!-- nothing -->
  </xsl:template>

  <!--
      @template lx:apply-templates
      Apply templates on the nodes of the XML Response (lx:response) specified using XPath expressions.
    -->
  <xsl:template match="lx:apply-templates"
		name="lx:apply-templates">
    <!-- @param The XPath expression to evaluate. -->
    <xsl:param name="xpath" select="@select"/>

    <xsl:call-template name="lx.xpath:expression-to-templates">
      <xsl:with-param name="expression" select="$xpath"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="lx.xpath:expression-to-value">
    <!-- @param The XPath expression to evaluate. -->
    <xsl:param name="expression"/>
    <!-- @param The root node (/) to use. -->
    <xsl:param name="root" select="/ | .. | $LX_RESPONSE | $LX_TEMPLATE"/>

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
	<xsl:call-template name="lx.xpath:expression-to-value">
	  <xsl:with-param name="expression" select="$new_path"/>
          <xsl:with-param name="root" select="$root//node()[name()=$node]"/>
	</xsl:call-template>
      </xsl:when>
      <!-- FIXME: Not working. -->
      <!-- <xsl:when test="$operator = '//@'"> -->
      <!--   <xsl:call-template name="lx.xpath:expression-to-value"> -->
      <!--     <xsl:with-param name="expression" select="$new_path"/> -->
      <!--     <xsl:with-param name="root" select="$root//@*[$node='*' or name()=$node]"/> -->
      <!--   </xsl:call-template> -->
      <!-- </xsl:when> -->
      <xsl:when test="$operator = '@' or $operator = '/@'">
	<xsl:call-template name="lx.xpath:expression-to-value">
	  <xsl:with-param name="expression" select="$new_path"/>
	  <xsl:with-param name="root" select="$root/@*[$node='*' or name()=$node]"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="$operator = '#'">
	<xsl:call-template name="lx.xpath:expression-to-value">
	  <xsl:with-param name="expression" select="$new_path"/>
	  <xsl:with-param name="root" select="$root/node()[@id=$node]"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="$operator = '/' or ($operator = '' and $node != '')">
	<xsl:call-template name="lx.xpath:expression-to-value">
	  <xsl:with-param name="expression" select="$new_path"/>
          <xsl:with-param name="root" select="$root/node()[name()=$node or $node='*']"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="$operator = '..'">
        <xsl:call-template name="lx.xpath:expression-to-value">
	  <xsl:with-param name="expression" select="$new_path"/>
          <xsl:with-param name="root" select="$root/parent::*[(name()=$node and $node!='') or $node='']"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="$operator = '['">
	<xsl:call-template name="lx.xpath:expression-to-value">
	  <xsl:with-param name="expression" select="substring-after($new_path, ']')"/>
	  <xsl:with-param name="root" select="$root[position()=$node]"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$root"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="lx.xpath:expression-to-templates">
    <!-- @param The XPath expression to evaluate. -->
    <xsl:param name="expression"/>
    <!-- @param The root node (/) to use. -->
    <xsl:param name="root" select="/ | .. | $LX_RESPONSE | $LX_TEMPLATE"/>

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
	<xsl:call-template name="lx.xpath:expression-to-templates">
	  <xsl:with-param name="expression" select="$new_path"/>
          <xsl:with-param name="root" select="$root//node()[(name()=$node and $node!='') or $node='']"/>
	</xsl:call-template>
      </xsl:when>
      <!-- FIXME: Not working. -->
      <!-- <xsl:when test="$operator = '//@'"> -->
      <!--   <xsl:call-template name="lx.xpath:expression-to-templates"> -->
      <!--     <xsl:with-param name="expression" select="$new_path"/> -->
      <!--     <xsl:with-param name="root" select="$root//@*[$node='*' or name()=$node]"/> -->
      <!--   </xsl:call-template> -->
      <!-- </xsl:when> -->
      <xsl:when test="$operator = '@' or $operator = '/@'">
	<xsl:call-template name="lx.xpath:expression-to-templates">
	  <xsl:with-param name="expression" select="$new_path"/>
	  <xsl:with-param name="root" select="$root/@*[$node='*']|$root/@*[name()=$node]"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="$operator = '/' or ($operator = '' and $node != '')">
	<xsl:call-template name="lx.xpath:expression-to-templates">
	  <xsl:with-param name="expression" select="$new_path"/>
          <xsl:with-param name="root" select="$root/node()[(name()=$node or $node='*')]"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="$operator = '['">
	<xsl:call-template name="lx.xpath:expression-to-templates">
	  <xsl:with-param name="expression" select="substring-after($new_path, ']')"/>
	  <xsl:with-param name="root" select="$root[position()=$node]"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="$operator = '#'">
	<xsl:call-template name="lx.xpath:expression-to-templates">
	  <xsl:with-param name="expression" select="$new_path"/>
	  <xsl:with-param name="root" select="$root/node()[id=$node]"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates select="$root"/>
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

    <xsl:choose>

      <xsl:when test="starts-with($expression, '//')">
        <xsl:value-of select="'//'"/>
      </xsl:when>

      <xsl:when test="starts-with($expression, '/@')">
        <xsl:value-of select="'/@'"/>
      </xsl:when>

      <!-- FIXME: Not working. -->
      <!-- <xsl:when test="starts-with($expression, '//@')"> -->
      <!--   <xsl:value-of select="'//@'"/> -->
      <!-- </xsl:when> -->

      <xsl:when test="starts-with($expression, '..')">
        <xsl:value-of select="'..'"/>
      </xsl:when>

      <xsl:otherwise>
        <xsl:variable name="char" select="substring($expression, 1, 1)"/>
        <xsl:choose>
          <xsl:when test="$char = ' '">
	    <xsl:call-template name="lx.xpath:get-operator">
	      <xsl:with-param name="expression" select="normalize-space($expression)"/>
	    </xsl:call-template>
          </xsl:when>
          <xsl:when test="$char != '' and contains($LX_XPATH_OPERATORS, $char)">
	    <xsl:value-of select="$char"/>
          </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="lx:include">
    <xsl:apply-templates select="document(@href)"/>
  </xsl:template>

  <xsl:template match="text()" priority="10">
  	<xsl:if test="string-length(normalize-space(.))">
  		<xsl:value-of select="."/>
  	</xsl:if>
  </xsl:template>

  <xsl:template match="lx:attribute">
  	<xsl:attribute name="{@name}">
  		<xsl:apply-templates select="node()"/>
  	</xsl:attribute>
  </xsl:template>

  <xsl:template match="lx:copy-of">
    <xsl:copy-of select="node()"/>
  </xsl:template>

</xsl:stylesheet>
