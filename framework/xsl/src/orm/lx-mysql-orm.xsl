<?xml version="1.0" encoding="UTF-8"?>

<?xml-stylesheet type="text/xsl" href="../lx-doc.xsl"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.aerys.in"
                version="1.0">

  <xsl:variable name="LX_TABLE_PREFIX" select="'lx'"/>

  <xsl:variable name="LX_TABLE_NAME">
    <xsl:choose>
      <xsl:when test="/lx:model/@table">
	<xsl:value-of select="/lx:model/@table"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($LX_TABLE_PREFIX, /lx:model/@name)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!--
      @template lx:select
      SELECT database request template.
    -->
  <xsl:template match="lx:select">
    <xsl:text>SELECT </xsl:text>
    <xsl:choose>
      <xsl:when test="lx:get">
	<xsl:call-template name="lx:for-each">
	  <xsl:with-param name="collection" select="lx:get"/>
	  <xsl:with-param name="delimiter" select="', '"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="lx:for-each">
	  <xsl:with-param name="collection" select="//lx:property/@name"/>
	  <xsl:with-param name="begin" select="'`'"/>
	  <xsl:with-param name="delimiter" select="'`, `'"/>
	  <xsl:with-param name="end" select="'`'"/>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text> FROM </xsl:text>
    <!-- TABLE -->
    <xsl:value-of select="concat('`', $LX_TABLE_NAME, '`')"/>
    <!-- INNER JOIN -->
    <xsl:apply-templates select="lx:inner-join"/>
    <!-- WHERE -->
    <xsl:apply-templates select="lx:where|lx:not"/>
    <!-- SORT -->
    <xsl:call-template name="lx:for-each">
      <xsl:with-param name="begin" select="' ORDER BY '"/>
      <xsl:with-param name="collection" select="lx:order-by"/>
      <xsl:with-param name="delimiter" select="', '"/>
    </xsl:call-template>
    <!-- LIMIT -->
    <xsl:if test="@limit">
      <xsl:text> LIMIT </xsl:text>
      <xsl:apply-templates select="@offset"/>
      <xsl:apply-templates select="@limit"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="lx:select/@offset | lx:select/@limit">
    <xsl:choose>
      <xsl:when test="ancestor::lx:static-method/lx:argument/@name = .">
        <xsl:value-of select="concat(':', ., '_', generate-id())"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="string(.)"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="name() = 'offset'">
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:template>

  <!--
      @template lx:delete
      DELETE database request template.
    -->
  <xsl:template match="lx:delete">
    <xsl:text>DELETE FROM </xsl:text>
    <xsl:value-of select="concat('`', $LX_TABLE_NAME, '`')"/>
    <!-- WHERE -->
    <xsl:apply-templates select="lx:where|lx:not"/>
  </xsl:template>

  <!--
      @template lx:update
      UPDATE database request template.
    -->
  <xsl:template match="lx:update"
                name="lx:update">
    <xsl:text>UPDATE</xsl:text>
    <xsl:value-of select="concat(' `', $LX_TABLE_NAME, '`')"/>
    <!-- SET -->
    <xsl:text> SET</xsl:text>
    <xsl:choose>
      <xsl:when test="lx:set">
	<xsl:call-template name="lx:for-each">
	  <xsl:with-param name="begin" select="' '"/>
	  <xsl:with-param name="collection" select="lx:set"/>
	  <xsl:with-param name="delimiter" select="', '"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:for-each select="/lx:model/lx:property[not(@read-only)]">
	  <xsl:if test="position() != 1">
	    <xsl:text>,</xsl:text>
	  </xsl:if>
	  <xsl:text> </xsl:text>
	  <xsl:value-of select="concat('`', @name, '`')"/>
	  <xsl:text>=:</xsl:text>
	  <xsl:value-of select="concat(@name, '_', generate-id(.))"/>
	</xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
    <!-- WHERE -->
    <xsl:apply-templates select="lx:where|lx:not"/>
  </xsl:template>

  <!--
      @template lx:insert
      INSERT database request template.
    -->
  <xsl:template match="lx:insert"
                name="lx:insert">
    <xsl:text>INSERT INTO </xsl:text>
    <xsl:value-of select="concat('`', $LX_TABLE_NAME, '`')"/>
    <xsl:text> (</xsl:text>
    <xsl:choose>
      <xsl:when test="lx:set">
	<xsl:call-template name="lx:for-each">
	  <xsl:with-param name="collection" select="lx:set"/>
	  <xsl:with-param name="delimiter" select="', '"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:for-each select="/lx:model/lx:property">
	  <xsl:if test="position() != 1">
	    <xsl:text>, </xsl:text>
	  </xsl:if>
	  <xsl:value-of select="concat('`', @name, '`')"/>
	</xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>)</xsl:text>
    <xsl:text> VALUES (</xsl:text>
    <xsl:choose>
      <xsl:when test="lx:set">
	<xsl:call-template name="lx:for-each">
	  <xsl:with-param name="begin" select="':'"/>
	  <xsl:with-param name="collection" select="lx:set"/>
	  <xsl:with-param name="delimiter" select="', :'"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:for-each select="/lx:model/lx:property">
	  <xsl:if test="position() != 1">
	    <xsl:text>, </xsl:text>
	  </xsl:if>
	  <xsl:value-of select="concat(':', @name, '_', generate-id())"/>
	</xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <!--
      @template lx:insert-or-update
      INSERT INTO ... ON DUPLICATE ENTRY request template.
    -->
  <xsl:template match="lx:insert-or-update">
    <xsl:call-template name="lx:insert"/>
    <xsl:text> ON DUPLICATE KEY UPDATE</xsl:text>
    <xsl:choose>
      <xsl:when test="lx:set">
	<xsl:call-template name="lx:for-each">
	  <xsl:with-param name="begin" select="' '"/>
	  <xsl:with-param name="collection" select="lx:set"/>
	  <xsl:with-param name="delimiter" select="', '"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:for-each select="/lx:model/lx:property[not(@read-only)]">
	  <xsl:if test="position() != 1">
	    <xsl:text>,</xsl:text>
	  </xsl:if>
	  <xsl:text> </xsl:text>
	  <xsl:value-of select="concat('`', @name, '`')"/>
	  <xsl:text>=:</xsl:text>
	  <xsl:value-of select="concat(@name, '_', generate-id(.))"/>
	</xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="lx:count">
    <xsl:text>SELECT COUNT</xsl:text>
    <xsl:text>(</xsl:text>

    <xsl:choose>
      <xsl:when test="@property">
        <xsl:text>DISTINCT </xsl:text>
	<xsl:value-of select="concat('`', @property, '`')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>*</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>)</xsl:text>
    <xsl:text> FROM </xsl:text>
    <!-- TABLE -->
    <xsl:value-of select="concat('`', $LX_TABLE_NAME, '`')"/>

    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="lx:order-by">
    <xsl:value-of select="@property"/>
    <xsl:if test="@desc = 'true'">
      <xsl:text> DESC</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="lx:get">
    <xsl:if test="@model">
      <xsl:value-of select="concat($DB_PREFIX, @model, '.')" />
    </xsl:if>

    <xsl:value-of select="concat('`', @property, '`')"/>
  </xsl:template>

  <xsl:template match="lx:set">
    <xsl:choose>
      <xsl:when test="@value">
	<xsl:value-of select="concat('`', @property, '`', ' = :', @value)"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="concat('`', @property, '`', ' = :', @property, '_', generate-id(.))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="lx:inner-join">
  	<xsl:text> INNER JOIN </xsl:text>
  	<xsl:value-of select="concat($DB_PREFIX, lx:external-property/@model)" />
  	<xsl:text> ON </xsl:text>
  	<xsl:value-of select="concat($LX_TABLE_NAME, '.`', lx:internal-property/@name, '`')" />
	<xsl:text> = </xsl:text>
  	<xsl:value-of select="concat($DB_PREFIX, lx:external-property/@model, '.`', lx:internal-property/@name, '`')" />
  </xsl:template>





  <xsl:template match="lx:where">
    <xsl:variable name="property" select="@property"/>

    <xsl:if test="not(ancestor::lx:where or preceding-sibling::lx:where)">
      <xsl:text> WHERE </xsl:text>
    </xsl:if>

    <xsl:if test="preceding-sibling::lx:where">
      <xsl:text> OR </xsl:text>
    </xsl:if>

    <xsl:value-of select="concat('`', $property, '`')"/>

    <xsl:if test="@value and @operator">
      <xsl:variable name="value" select="concat(':', @property, '_', generate-id())"/>
      <xsl:variable name="type" select="/lx:model/lx:property[@name = $property]/@type"/>

      <xsl:variable name="operator">
        <xsl:choose>
	  <xsl:when test="$type = 'string' and @operator = 'eq'">
	    <xsl:text> LIKE </xsl:text>
	  </xsl:when>
	  <xsl:when test="$type = 'string' and @operator = 'ne'">
	    <xsl:text> NOT LIKE </xsl:text>
	  </xsl:when>
          <xsl:when test="@operator = 'eq'">
            <xsl:text>=</xsl:text>
          </xsl:when>
          <xsl:when test="@operator = 'lt'">
            <xsl:text>&lt;</xsl:text>
          </xsl:when>
          <xsl:when test="@operator = 'le'">
            <xsl:text>&lt;=</xsl:text>
          </xsl:when>
          <xsl:when test="@operator = 'gt'">
            <xsl:text>&gt;</xsl:text>
          </xsl:when>
          <xsl:when test="@operator = 'ge'">
            <xsl:text>&gt;=</xsl:text>
          </xsl:when>
          <xsl:when test="@operator = 'in'">
            <xsl:text> IN </xsl:text>
          </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="concat(' ', @operator, ' ')"/>
	  </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:value-of select="concat($operator, $value)"/>
    </xsl:if>

    <xsl:if test="lx:where">
      <xsl:text> AND </xsl:text>
      <xsl:if test="count(lx:where) &gt; 1">
        <xsl:text>(</xsl:text>
      </xsl:if>
      <xsl:apply-templates select="lx:where"/>
      <xsl:if test="count(lx:where) &gt; 1">
        <xsl:text>)</xsl:text>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="lx:not">
    <xsl:text>!(</xsl:text>
    <xsl:apply-templates select="node()"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

</xsl:stylesheet>
