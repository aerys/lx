<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:lx="http://lx.promethe.net"
                version="1.0">

  <xsl:variable name="LX_TABLE">
    <xsl:value-of select="concat($LX_PREFIX, /lx:model/@name)"/>
  </xsl:variable>

  <xsl:template match="lx:select | lx:delete | lx:update | lx:insert">
    <xsl:variable name="result">
      <xsl:apply-templates select="." mode="echo"/>
    </xsl:variable>
    <xsl:value-of select="normalize-space($result)"/>
  </xsl:template>

  <xsl:template match="lx:select" mode="echo">
    <![CDATA[SELECT * FROM]]>
    <!-- TABLE -->
    <xsl:value-of select="$LX_TABLE"/>
    <!-- WHERE -->
    <xsl:call-template name="lx:iterate">
      <xsl:with-param name="prologue" select="' WHERE '"/>
      <xsl:with-param name="collection" select="lx:condition"/>
      <xsl:with-param name="delimiter" select="' AND '"/>
    </xsl:call-template>
    <!-- SORT -->
    <xsl:call-template name="lx:iterate">
      <xsl:with-param name="prologue" select="' ORDER BY '"/>
      <xsl:with-param name="collection" select="lx:sort"/>
      <xsl:with-param name="delimiter" select="', '"/>
    </xsl:call-template>
    <!-- LIMIT -->
    <xsl:if test="@limit">
      LIMIT
      <xsl:if test="@offset">
	<xsl:value-of select="@offset"/>,
      </xsl:if>
      <xsl:value-of select="@limit"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="lx:delete" mode="echo">
    <![CDATA[DELETE * FROM ]]>
    <xsl:value-of select="$LX_TABLE"/>
    <!-- WHERE -->
    <xsl:call-template name="lx:iterate">
      <xsl:with-param name="prologue" select="' WHERE '"/>
      <xsl:with-param name="collection" select="lx:condition"/>
      <xsl:with-param name="delimiter" select="' AND '"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="lx:update" mode="echo">
    <![CDATA[UPDATE ]]>
    <xsl:value-of select="$LX_TABLE"/>
    <!-- SET -->
    SET
    <xsl:call-template name="lx:iterate">
      <xsl:with-param name="collection" select="lx:value"/>
      <xsl:with-param name="delimiter" select="', '"/>
    </xsl:call-template>
    <!-- WHERE -->
    <xsl:call-template name="lx:iterate">
      <xsl:with-param name="prologue" select="' WHERE '"/>
      <xsl:with-param name="collection" select="lx:condition"/>
      <xsl:with-param name="delimiter" select="' AND '"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="lx:value">
    <xsl:value-of select="concat(@property, '=:', @property)"/>
  </xsl:template>

  <xsl:template match="lx:condition">
    <xsl:variable name="property" select="@property"/>
    <xsl:variable name="value" select="concat(':', $property)"/>
    <xsl:variable name="type" select="//lx:property[@name = $property]/@type"/>
    <xsl:variable name="operator">
      <xsl:choose>
	<xsl:when test="$type = 'string' and @operator = '='">
	  LIKE
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="@operator"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:value-of select="concat($property, $operator, $value)"/>
  </xsl:template>

  <xsl:template match="lx:insert" mode="echo">
    INSERT INTO
    <xsl:value-of select="$LX_TABLE"/>
    <xsl:call-template name="lx:iterate">
      <xsl:with-param name="prologue" select="' ('"/>
      <xsl:with-param name="collection" select="lx:value/@property"/>
      <xsl:with-param name="delimiter" select="', '"/>
    </xsl:call-template>)
      VALUES
    <xsl:call-template name="lx:iterate">
      <xsl:with-param name="prologue" select="'(:'"/>
      <xsl:with-param name="collection" select="lx:value/@property"/>
      <xsl:with-param name="delimiter" select="', :'"/>
    </xsl:call-template>)
  </xsl:template>

  <xsl:template match="lx:sort">
    <xsl:value-of select="@property"/>
    <xsl:if test="@desc"> DESC</xsl:if>
  </xsl:template>

</xsl:stylesheet>
