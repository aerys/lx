<?xml version="1.0" encoding="UTF-8"?>

<?xml-stylesheet type="text/xsl" href="../lx-doc.xsl"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.aerys.in"
                version="1.0">

  <xsl:output omit-xml-declaration="yes"
	      method="text"
	      encoding="utf-8"/>

  <xsl:strip-space elements="*"/>

  <xsl:include href="lx-mysql-orm.xsl"/>
  <xsl:include href="../lx-std.xsl"/>

  <xsl:template match="/">
    <xsl:value-of select="concat($LX_LT, '?php', ' ')"/>

    <xsl:apply-templates select="/lx:model" />

    <xsl:value-of select="concat('?', $LX_GT)"/>
  </xsl:template>

  <xsl:template match="lx:model">
    <!-- Model class -->
    <xsl:text>class </xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text> extends AbstractModel {</xsl:text>

    <!-- class constants -->
    <xsl:apply-templates select="lx:const"/>

    <!-- class properties -->
    <xsl:apply-templates select="lx:property"/>

    <!-- constructor declaration -->
    <xsl:text>public function </xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>(){</xsl:text>
    <!-- parent constructor call -->
    <xsl:text>parent::AbstractModel(</xsl:text>
    <xsl:value-of select="concat($LX_QUOTE, @database, $LX_QUOTE)"/>
    <xsl:text>);}</xsl:text>

    <xsl:apply-templates select="lx:static-method"/>
    <xsl:apply-templates select="lx:method"/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="lx:property">
    <xsl:text>protected $</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:if test="@value">
      <xsl:text>=</xsl:text>
      <xsl:value-of select="@value"/>
    </xsl:if>
    <xsl:text>;</xsl:text>
  </xsl:template>

  <xsl:template match="lx:argument">
    <xsl:value-of select="concat('$', @name)"/>
  </xsl:template>

  <xsl:template match="lx:const">
    <xsl:value-of select="concat('const ', @name, '=', @value, ';')"/>
  </xsl:template>

  <xsl:template match="lx:property" mode="set">

      <xsl:call-template name="lx:set-property">
	<xsl:with-param name="property" select="@name"/>
	<xsl:with-param name="value" select="@name"/>
      </xsl:call-template>

  </xsl:template>

  <xsl:template match="lx:set | lx:condition"
		name="lx:set-property"
		mode="set">
    <xsl:param name="property" select="@property"/>
    <xsl:param name="value">
      <xsl:choose>
	<xsl:when test="@value">
	  <xsl:value-of select="@value"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="@property"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:param>

    <xsl:variable name="method" select="ancestor::lx:method | ancestor::lx:static-method"/>
    <xsl:variable name="isArgument" select="boolean($method/lx:argument[@name = $value])"/>
    <xsl:variable name="isProperty" select="boolean(/lx:model/lx:property[@name = $value])"/>

    <!-- variable name -->
    <xsl:variable name="set_value">
      <xsl:choose>
	<xsl:when test="$isArgument">
	  <xsl:value-of select="concat('$', $value)"/>
	</xsl:when>
	<xsl:when test="$isProperty">
	  <xsl:value-of select="concat('$this->', $value)"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$value"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- variable type -->
    <xsl:variable name="set_type">
      <xsl:choose>
	<xsl:when test="$isArgument or $isProperty">
	  <xsl:value-of select="/lx:model/lx:property[@name = $property]/@type"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:call-template name="lx:typeof">
	    <xsl:with-param name="input" select="$value"/>
	  </xsl:call-template>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- set method -->
    <xsl:variable name="set_method">
      <xsl:choose>
	<xsl:when test="$set_type = 'integer'">
	  <xsl:value-of select="'setInteger'"/>
	</xsl:when>
	<xsl:when test="$set_type = 'float'">
	  <xsl:value-of select="'setFloat'"/>
	</xsl:when>
	<xsl:when test="$set_type = 'boolean'">
	  <xsl:value-of select="'setBoolean'"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="'setString'"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:value-of select="concat('->', $set_method, '(', $LX_QUOTE, $property, '_', generate-id(.), $LX_QUOTE, ',', $set_value, ')')"/>
  </xsl:template>

  <xsl:template match="lx:static-method">
    <xsl:variable name="args">
      <xsl:call-template name="lx:for-each">
	<xsl:with-param name="collection" select="lx:argument"/>
	<xsl:with-param name="delimiter" select="','"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="sql">
      <xsl:apply-templates select="lx:select | lx:delete | lx:update"/>
    </xsl:variable>
    <xsl:text>static public function </xsl:text>
    <xsl:value-of select="concat(@name, '(', $args, ')')"/>
    <xsl:text>{$models=array();$db=DatabaseFactory::create('</xsl:text>
    <xsl:value-of select="//lx:model/@database"/>
    <xsl:text>');$query=$db->createQuery(</xsl:text>
    <xsl:value-of select="concat($LX_QUOTE, $sql, $LX_QUOTE)"/>
    <xsl:text>)</xsl:text>
    <xsl:call-template name="lx:set-query-properties"/>
    <xsl:text>;$result=$db->performQuery($query);if(!is_array($result))return($result);foreach($result as $i=>$record)</xsl:text>
    <xsl:text>{$model=new </xsl:text>
    <xsl:value-of select="//lx:model/@name"/>
    <xsl:text>();$model->loadArray($record);$models[]=$model;}</xsl:text>

    <!-- return -->
    <xsl:call-template name="lx:method-return"/>

    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="lx:method">
    <xsl:variable name="args">
      <xsl:call-template name="lx:for-each">
	<xsl:with-param name="collection" select="lx:argument"/>
	<xsl:with-param name="delimiter" select="','"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="sql">
      <xsl:apply-templates select="lx:select | lx:delete | lx:update | lx:insert"/>
    </xsl:variable>

    <xsl:text>public function </xsl:text>
    <xsl:value-of select="concat(@name, '(', $args, ')')"/>
    <xsl:text>{$db=DatabaseFactory::create('</xsl:text>
    <xsl:value-of select="//lx:model/@database"/>
    <xsl:text>');$query=$db->createQuery(</xsl:text>
    <xsl:value-of select="concat($LX_QUOTE, $sql, $LX_QUOTE)"/>
    <xsl:text>)</xsl:text>

    <xsl:call-template name="lx:set-query-properties"/>

    <xsl:text>;$db->performQuery($query);</xsl:text>

    <!-- return -->
    <xsl:call-template name="lx:method-return"/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template name="lx:set-query-properties">
    <xsl:apply-templates select="descendant::node()[@property]" mode="set"/>
    <xsl:if test="(lx:update or lx:insert) and not(descendant::lx:set)">
      <xsl:apply-templates select="/lx:model/lx:property[not(@read-only)]" mode="set"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="lx:method-return">
    <xsl:text>return </xsl:text>
    <xsl:choose>
      <xsl:when test="lx:select/@limit=1">
	<xsl:text>count($models)?$models[0]:NULL</xsl:text>
      </xsl:when>
      <xsl:when test="lx:insert">
	<xsl:text>$db->getInsertId()</xsl:text>
      </xsl:when>
      <xsl:when test="../lx:static-method = current()">
	<xsl:text>$models</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>$this</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>;</xsl:text>
  </xsl:template>

</xsl:stylesheet>
