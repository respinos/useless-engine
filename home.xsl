<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:m="http://example.com/ns/md-corpus"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="#all"
                version="3.0">

  <!-- ==================================================================
       Turns the m:entry sequence aggregated off build-site.xpl's loop
       into a sitemaps.org urlset.

       Input:  <m:sitemap>
                 <m:entry path="intro.html" date="2026-03-01"
                          source="file:/.../intro.md"
                          stored="file:/.../build/intro.html">Intro</m:entry>
                 ...
               </m:sitemap>
       ================================================================== -->

  <xsl:param name="base-url" as="xs:string" select="'https://example.com/'"/>

  <xsl:output 
    method="xhtml" 
    html-version="5.0" 
    encoding="UTF-8" 
    indent="yes" 
    omit-xml-declaration="yes"
    suppress-indentation="xhtml:pre" />

  <xsl:import href="_layout.xsl"/>

  <!-- on-no-match="fail" (below) switches off the built-in rules, which
       includes the one that would otherwise walk from the document node
       into its element child - so that step has to be explicit. -->
  <!-- <xsl:template match="document-node()">
     <xsl:apply-templates select="m:snippets" />
  </xsl:template> -->

  <xsl:template match="/m:snippets" mode="head">
    <xhtml:title>Useless Notes</xhtml:title>
  </xsl:template>

  <xsl:template match="/m:snippets">
    <xhtml:h1>Useless Notes</xhtml:h1>
    <xhtml:p>Something something twilight years of a webfarmer.</xhtml:p>
    <xsl:for-each select="xhtml:section[position() &lt;= 3]">
      <xsl:apply-templates />
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="/m:snippets" mode="original">
    <xhtml:html lang="en">
      <xhtml:head>
        <xhtml:meta charset="UTF-8" />
        <xhtml:meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <xhtml:title>Useless Notes</xhtml:title>
        <xhtml:link rel="stylesheet" href="static/css/styles.css" />
      </xhtml:head>
      <xhtml:body>
        <xhtml:div class="container">
          <xhtml:main class="main">
            <xhtml:h1>Useless Notes</xhtml:h1>
            <xhtml:p>Something something twilight years of a webfarmer.</xhtml:p>
            <xsl:for-each select="xhtml:section[position() &lt;= 3]">
              <xsl:apply-templates />
            </xsl:for-each>
          </xhtml:main>
        </xhtml:div>
      </xhtml:body>
    </xhtml:html>  
  </xsl:template>

  <!-- Nothing else should reach the output. -->
  <xsl:mode on-no-match="shallow-copy"/>

</xsl:stylesheet>
