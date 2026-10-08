<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:m="http://example.com/ns/md-corpus"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                exclude-result-prefixes="#all"
                version="3.0">

  <xsl:template match="m:head">
    <xhtml:title><xsl:value-of select="m:title"/></xhtml:title>
    <xhtml:meta charset="UTF-8"/>
    <xhtml:meta name="dc.identifier" content="{m:id}"/>
    <xhtml:meta name="dcterms.created" content="{m:created_at}"/>
    <xhtml:meta name="dcterms.modified" content="{m:updated_at}"/>
    <xsl:apply-templates select="m:tags/m:tag" />
  </xsl:template>

  <xsl:template match="m:tags/m:tag">
    <xhtml:meta name="dc.subject" content="{.}"/>
  </xsl:template>

  <xsl:template match="m:doc">
    <xhtml:header>
      <xhtml:h2>
        <xhtml:a rel="bookmark">
          <xsl:if test="normalize-space($path) != ''">
            <xsl:attribute name="href"><xsl:value-of select="concat('/', $path)" /></xsl:attribute>
          </xsl:if>
          <xsl:value-of select="/m:post/m:head/m:title"/>
        </xhtml:a>
      </xhtml:h2>
    </xhtml:header>
    <xhtml:section>
      <xsl:choose>
        <xsl:when test="$do-snippets = 'yes'">
          <xsl:apply-templates select="node()[1]" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates />
        </xsl:otherwise>
      </xsl:choose>
    </xhtml:section>
  </xsl:template>

  <xsl:template match="m:heading">
    <xsl:element name="xhtml:h{@level}">
      <xsl:apply-templates />
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="m:paragraph" >
    <xhtml:p>
      <xsl:apply-templates />
    </xhtml:p>
  </xsl:template>

  <xsl:template match="m:codeBlock" >
    <xhtml:pre><xhtml:code class="language-{@language}">
        <xsl:apply-templates />
    </xhtml:code></xhtml:pre>
  </xsl:template>

  <xsl:template match="m:blockquote" >
    <xhtml:blockquote>
      <xsl:apply-templates />
    </xhtml:blockquote>
  </xsl:template>

  <xsl:template match="m:bold">
    <xhtml:strong>
      <xsl:apply-templates />
    </xhtml:strong>
  </xsl:template>
  
  <xsl:template match="m:italic">
    <xhtml:em>
      <xsl:apply-templates />
    </xhtml:em>
  </xsl:template>
  
  <xsl:template match="m:strike">
    <xhtml:s>
      <xsl:apply-templates />
    </xhtml:s>
  </xsl:template>
  
   <xsl:template match="m:link">
    <xhtml:a href="{@href}">
      <xsl:apply-templates />
    </xhtml:a>
  </xsl:template>

  <xsl:template match="m:horizontalRule">
    <xhtml:hr/>
  </xsl:template>

  <xsl:template match="m:list[@type='bullet']">
    <xhtml:ul>
      <xsl:apply-templates select="m:li" />
    </xhtml:ul>
  </xsl:template>

  <xsl:template match="m:list[@type='ordered']">
    <xhtml:ol>
      <xsl:apply-templates select="m:li" />
    </xhtml:ol>
  </xsl:template>

  <xsl:template match="m:list[@type='task']">
    <xhtml:ul>
      <xsl:apply-templates select="m:li" />
    </xhtml:ul>
  </xsl:template>

  <xsl:template match="m:list[@type='task']/m:li">
    <xhtml:li>
      <xhtml:div class="task-list-item">
        <xhtml:div class="form-check">
          <xhtml:div class="form-checkbox">
            <xsl:if test="@checked = 'true'">
              <xsl:attribute name="data-checked">true</xsl:attribute>
            </xsl:if>
          </xhtml:div>
          <xsl:apply-templates />
        </xhtml:div>
      </xhtml:div>
    </xhtml:li>
  </xsl:template>

  <xsl:template match="m:li">
    <xhtml:li>
      <xsl:apply-templates />
    </xhtml:li>
  </xsl:template>

  <xsl:template match="m:list" mode="legacy">
    <xsl:message>BOO-YAH A LIST</xsl:message>
    <xsl:variable name="preceding-sibling" select="preceding-sibling::*[1]" />
    <xsl:choose>
      <xsl:when test="node-name($preceding-sibling) = node-name(.)"></xsl:when>
      <xsl:otherwise>
        <xsl:variable name="break" select="following-sibling::*[node-name(.) != node-name(current())][1]" />
        <xsl:variable name="list-items" select="self::*, following-sibling::*[node-name(.) = node-name(current())][empty($break) or . &lt;&lt; $break]" />
        <xsl:apply-templates select="$list-items[1]" mode="build-list">
          <xsl:with-param name="list-items" select="$list-items" />
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="m:list[@kind='bullet']" mode="build-list">
    <xsl:param name="list-items" />
    <xhtml:ul>
      <xsl:for-each select="$list-items">
        <xsl:apply-templates select="." mode="list-item" />
      </xsl:for-each>
    </xhtml:ul>
  </xsl:template>

  <xsl:template match="m:list[@kind='ordered']" mode="build-list">
    <xsl:param name="list-items" />
    <xhtml:ol>
      <xsl:for-each select="$list-items">
        <xsl:apply-templates select="." mode="list-item" />
      </xsl:for-each>
    </xhtml:ol>
  </xsl:template>

  <xsl:template match="m:list[@kind='task']" mode="build-list">
    <xsl:param name="list-items" />
    <m:debug>TASK LIST</m:debug>
    <xhtml:ul>
      <xsl:for-each select="$list-items">
        <xsl:apply-templates select="." mode="list-item-task" />
      </xsl:for-each>
    </xhtml:ul>
  </xsl:template>

  <xsl:template match="m:list" mode="list-item">
    <xhtml:li>
      <xsl:apply-templates  />
    </xhtml:li>
  </xsl:template>

  <xsl:template match="m:list" mode="list-item-task">
    <xhtml:li>
      <xhtml:div class="task-list-item">
        <xhtml:div class="form-check">
          <xhtml:div class="form-checkbox">
            <xsl:if test="@checked = 'true'">
              <xsl:attribute name="data-checked">true</xsl:attribute>
            </xsl:if>
          </xhtml:div>
        </xhtml:div>
        <xsl:apply-templates  />
      </xhtml:div>
    </xhtml:li>
  </xsl:template>

  <xsl:template match="m:table">
    <xsl:variable name="table-rows" select="m:tableRow" />
    <xsl:variable name="header-index">
      <xsl:choose>
        <xsl:when test="$table-rows[last()]/m:tableCell//m:bold">
          0
        </xsl:when>
        <xsl:when test="$table-rows[1]/m:tableCell//m:bold">
          1
        </xsl:when>
        <xsl:otherwise>
          0
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable> 
    <xhtml:table>
      <xsl:if test="$header-index = 1">
        <xhtml:thead>
          <xsl:apply-templates select="$table-rows[1]" mode="thead" />
        </xhtml:thead>
      </xsl:if>
      <xhtml:tbody>
        <xsl:apply-templates select="$table-rows[position() > $header-index]" mode="tbody" />
      </xhtml:tbody>
    </xhtml:table>
  </xsl:template>

  <xsl:template match="m:tableRow" mode="thead">
    <xhtml:tr>
      <xsl:for-each select="m:tableCell">
        <xhtml:th>
          <xsl:apply-templates />
        </xhtml:th>
      </xsl:for-each>
    </xhtml:tr>
  </xsl:template>

  <xsl:template match="m:tableRow" mode="tbody">
    <xhtml:tr>
      <xsl:for-each select="m:tableCell">
        <xsl:choose>
          <xsl:when test=".//m:bold">
            <xhtml:th>
              <xsl:apply-templates />
            </xhtml:th>
          </xsl:when>
          <xsl:otherwise>
            <xhtml:td>
              <xsl:apply-templates />
            </xhtml:td>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xhtml:tr>
  </xsl:template>                
               
</xsl:stylesheet>