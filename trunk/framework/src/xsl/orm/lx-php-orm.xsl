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
    <xsl:apply-templates select="lx:model" />
    <xsl:value-of select="concat('?', $LX_GT)"/>
  </xsl:template>

  <xsl:template match="lx:model">
    <!-- class -->
    <xsl:text>class </xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text> extends AbstractModel {private static $__db__;</xsl:text>
    <xsl:text>private static function db(){return self::$__db__?</xsl:text>
    <xsl:text>self::$__db__:self::$__db__=DatabaseFactory::create('</xsl:text>
    <xsl:value-of select="@database"/>
    <xsl:text>');}</xsl:text>

    <!-- constants -->
    <xsl:apply-templates select="lx:const"/>

    <!-- properties -->
    <xsl:apply-templates select="lx:property"/>

    <!-- constructor -->
    <xsl:text>public function </xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>(){parent::AbstractModel(self::db());}</xsl:text>

    <!-- methods -->
    <xsl:apply-templates select="lx:static-method | lx:method"/>

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

  <xsl:template name="lx:set-query-properties">
    <xsl:apply-templates select="descendant::node()[@property]" mode="set"/>
    <xsl:if test="(lx:update or lx:insert) and not(descendant::lx:set)">
      <xsl:apply-templates select="/lx:model/lx:property[not(@read-only)]" mode="set"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="lx:argument">
    <xsl:value-of select="concat('$', @name)"/>
  </xsl:template>

  <xsl:template match="lx:method | lx:static-method">
    <xsl:variable name="isStatic" select="name() = 'lx:static-method'"/>

    <!-- prototype -->
    <xsl:text>public </xsl:text>
    <xsl:if test="$isStatic">
      <xsl:text>static </xsl:text>
    </xsl:if>
    <xsl:text>function </xsl:text>
    <xsl:value-of select="concat(@name, '(')"/>
    <xsl:call-template name="lx:for-each">
      <xsl:with-param name="collection" select="lx:argument"/>
      <xsl:with-param name="delimiter" select="','"/>
    </xsl:call-template>
    <xsl:text>){</xsl:text>

    <!-- prepary query -->
    <xsl:text>$q=self::db()->createQuery('</xsl:text>
    <xsl:apply-templates select="lx:select | lx:delete | lx:update | lx:insert"/>
    <xsl:text>')</xsl:text>
    <xsl:call-template name="lx:set-query-properties"/>
    <xsl:text>;</xsl:text>

    <!-- perform query -->
    <xsl:if test="$isStatic">
      <xsl:text>$n=array();$r=</xsl:text>
    </xsl:if>
    <xsl:text>self::db()->performQuery($q);</xsl:text>

    <!-- fetch records -->
    <xsl:if test="$isStatic">
      <xsl:text>if(!is_array($r))return $r;foreach($r as $e)</xsl:text>
      <xsl:text>{$m=new </xsl:text>
      <xsl:value-of select="/lx:model/@name"/>
      <xsl:text>();$m->loadArray($e);$n[]=$m;}</xsl:text>
    </xsl:if>

    <!-- return -->
    <xsl:text>return </xsl:text>
    <xsl:choose>
      <xsl:when test="lx:select/@limit=1">
	<xsl:text>count($n)?$n[0]:NULL</xsl:text>
      </xsl:when>
      <xsl:when test="lx:insert">
	<xsl:text>self::db()->getInsertId()</xsl:text>
      </xsl:when>
      <xsl:when test="lx:delete">
      </xsl:when>
      <xsl:when test="../lx:static-method = current()">
	<xsl:text>$n</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>$this</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>;}</xsl:text>
  </xsl:template>
</xsl:stylesheet>
