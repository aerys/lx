<?xml version="1.0" encoding="UTF-8"?>

<?xml-stylesheet type="text/xsl" href="/views/lx-doc.xsl"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.promethe.net"
                version="1.0">

  <xsl:output omit-xml-declaration="yes"
	      method="text"
	      encoding="utf-8"/>

  <xsl:strip-space elements="*"/>

  <xsl:include href="lx-mysql.xsl"/>
  <xsl:include href="lx-templates.xsl"/>

  <xsl:template match="/">
    <xsl:value-of select="concat($LX_LT, '?php', $LX_LF, ' ')"/>

    <xsl:apply-templates select="/lx:model" />

    <xsl:value-of select="concat('?', $LX_GT)"/>
  </xsl:template>

  <xsl:template match="lx:model">
    <!-- Model class -->
    class <xsl:value-of select="@name"/> extends AbstractModel {

    <xsl:call-template name="lx:iterate">
      <xsl:with-param name="prologue" select="'protected '"/>
      <xsl:with-param name="delimiter" select="', '"/>
      <xsl:with-param name="collection" select="lx:property"/>
    </xsl:call-template>
    <xsl:text>;</xsl:text>

    public function <xsl:value-of select="@name"/>(){
    <!-- parent constructor call -->
    <xsl:text>parent::AbstractModel(</xsl:text>
    <xsl:value-of select="concat($LX_QUOTE, @database, $LX_QUOTE)"/>
    <xsl:text>);}</xsl:text>

    <xsl:apply-templates select="lx:method"/>
    }
  </xsl:template>

  <xsl:template match="lx:property | lx:argument">
    <xsl:value-of select="concat('$', @name)"/>
  </xsl:template>

  <xsl:template match="node()[@property][@value]" mode="set">

    <xsl:variable name="name">
      <xsl:value-of select="translate(@value, '$', '')"/>
    </xsl:variable>

    <xsl:variable name="isArgument" select="ancestor::lx:method/lx:argument[@name = $name]"/>

    <xsl:variable name="value">
      <xsl:choose>
	<xsl:when test="$isArgument">
	  <xsl:value-of select="concat('$', $name)"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="concat('$this->', $name)"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="type">
      <xsl:choose>
	<xsl:when test="$isArgument">
	  <xsl:value-of select="ancestor::*/lx:argument[@name = $name]/@type"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="/lx:model/lx:property[@name = $name]/@type"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="method">
      <xsl:choose>
	<xsl:when test="$type = 'integer'">
	  <xsl:value-of select="'$query->setInteger'"/>
	</xsl:when>
	<xsl:when test="$type = 'bool' or $type = 'boolean'">
	  <xsl:value-of select="'$query->setBoolean'"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="'$query->setString'"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:value-of select="concat($method, '(', $LX_QUOTE, @property, $LX_QUOTE, ', ', $value, ');', $LX_LF)"/>
  </xsl:template>

  <xsl:template match="lx:method[@static = 'true']">
    <xsl:variable name="args">
      <xsl:call-template name="lx:iterate">
	<xsl:with-param name="collection" select="lx:argument"/>
	<xsl:with-param name="delimiter" select="','"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="sql">
      <xsl:apply-templates select="lx:select | lx:delete | lx:update"/>
    </xsl:variable>
    static public function <xsl:value-of select="concat(@name, '(', $args, ')')"/>{
	$models = array();

	$db = DatabaseFactory::create('<xsl:value-of select="//lx:model/@database"/>');
	$query = $db->createQuery(<xsl:value-of select="concat($LX_QUOTE, $sql, $LX_QUOTE)"/>);

    <xsl:choose>
      <xsl:when test="lx:update or lx:insert">
	<xsl:apply-templates select="/lx:model/lx:property" mode="set"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates select="descendant::node()[@property][@value]" mode="set"/>
      </xsl:otherwise>
    </xsl:choose>


	$result = $db->performQuery($query);

	foreach ($result as $i => $record)
	{
	  $model = new <xsl:value-of select="//lx:model/@name"/>();
	  $model->loadArray($record);
	  $models[] = $model;
	}

	return($models);}
  </xsl:template>

  <xsl:template match="lx:method">
    <xsl:variable name="args">
      <xsl:call-template name="lx:iterate">
	<xsl:with-param name="collection" select="lx:argument"/>
	<xsl:with-param name="delimiter" select="','"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="sql">
      <xsl:apply-templates select="lx:select | lx:delete | lx:update | lx:insert"/>
    </xsl:variable>
    public function <xsl:value-of select="concat(@name, '(', $args, ')')"/>{
	$db = DatabaseFactory::create('<xsl:value-of select="//lx:model/@database"/>');
	$query = $db->createQuery(<xsl:value-of select="concat($LX_QUOTE, $sql, $LX_QUOTE)"/>);

    <xsl:apply-templates select="descendant::node()[@property][@value]" mode="set"/>

	$db->performQuery($query);

	return($this);}
  </xsl:template>


</xsl:stylesheet>

