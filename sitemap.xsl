<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:m="http://example.com/ns/md-corpus"
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

  <xsl:output method="xml" indent="yes"/>

  <!-- on-no-match="fail" (below) switches off the built-in rules, which
       includes the one that would otherwise walk from the document node
       into its element child - so that step has to be explicit. -->
  <xsl:template match="document-node()">
    <xsl:apply-templates select="m:sitemap"/>
  </xsl:template>

  <xsl:template match="/m:sitemap">
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
      <xsl:for-each select="m:entry">
        <xsl:sort select="@path"/>
        <url>
          <!-- resolve-uri, not concat: it handles the trailing slash on
               base-url and any subdirectory in @path correctly. -->
          <loc><xsl:value-of select="resolve-uri(@path, $base-url)"/></loc>

          <!-- lastmod is optional and must be a valid date, so a garbled
               or absent front matter date is skipped rather than emitted
               as something a validator will reject. -->
          <xsl:if test="@lastmod castable as xs:date">
            <lastmod><xsl:value-of select="@lastmod"/></lastmod>
          </xsl:if>
        </url>
      </xsl:for-each>
    </urlset>
  </xsl:template>

  <!-- Nothing else should reach the output. -->
  <xsl:mode on-no-match="fail"/>

</xsl:stylesheet>
