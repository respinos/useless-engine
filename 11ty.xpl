<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:m="http://example.com/ns/md-corpus"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                version="3.1"
                name="markdown-corpus">


  <p:output port="result" serialization="map{'indent': true()}" sequence="true" />

  <p:option name="source-dir" as="xs:string" required="true"/>
  <p:option name="output-dir"      as="xs:anyURI" required="true"/>
  <p:option name="recursive" as="xs:boolean" select="true()"/>
  <p:option name="base-url"        as="xs:string" select="'https://notes.unusable.lol/'"/>
  <p:option name="page-stylesheet" as="xs:string" select="'identity.xsl'"/>
  <p:option name="sitemap-name"    as="xs:string" select="'sitemap.xml'"/>  

  <p:option name="debug-messages-on" as="xs:boolean" select="true()"/>


  <!-- 1. Enumerate the directory. Produces one c:directory document. -->
  <p:directory-list name="listing"
                    path="{$source-dir}"
                    include-filter="\.(json)$"
                    max-depth="{if ($recursive) then 'unbounded' else '1'}"/>


  <p:for-each name="convert">
    <p:with-input select="(reverse(//c:file))[position() ge 1]"/>

    <p:output port="result"  primary="true" sequence="true"
              pipe="result-uri@store-page"/>
    <p:output port="entries" sequence="true" 
              pipe="result@entry"/>
    <p:output port="snippets" sequence="true"
              pipe="result@snippet"/>

    <p:variable name="href" as="xs:anyURI"
                select="resolve-uri(/c:file/@name, base-uri(/c:file))"/>

    <!-- 2a. Load the file as text, before any Markdown parsing. -->
    <p:load href="{$href}" content-type="application/json" name="load-json"/>
    <p:message test="{$debug-messages-on}" select="Starting computation at {current-dateTime()}"/>

    <!-- <p:identity name="doc"/> -->
    <p:cast-content-type content-type="application/xml" name="doc"/>

    <p:variable name="path" as="xs:string" select="concat(/m:post/m:head/m:id, '.html')">
      <p:pipe step="transform"/>
    </p:variable>

    <p:variable name="target" as="xs:anyURI"
                select="resolve-uri($path, $output-dir)"/>

    <p:xslt name="transform">
      <p:with-input port="source"><p:pipe step="doc"/></p:with-input>
      <p:with-input port="stylesheet" href="json2xml.xsl"/>
      <!-- <p:with-option name="parameters" select="map{
        QName('', 'base-url'): $base-url,
        QName('', 'source-uri'): $src
      }"/> -->
    </p:xslt>

    <p:xslt name="render">
      <p:with-input port="source"><p:pipe step="transform"/></p:with-input>
      <p:with-input port="stylesheet" href="{$page-stylesheet}"/>
    </p:xslt>

    <!-- Side effect. The rendered page continues on result; the URI it
         landed at appears on result-uri, which is what this loop's
         primary output collects. -->
    <p:message test="{$debug-messages-on}" select=":: {$target}"/>

    <p:store name="store-page" href="{$target}"
             serialization="map{'method': 'html', 'html-version': '5',
                                'indent': true()}"/>

    <p:xslt name="snippet">
      <p:with-input port="source"><p:pipe step="transform"/></p:with-input>
      <p:with-input port="stylesheet" href="frugal2snippet.xsl"/>
      <p:with-option name="parameters" select="map{
        QName('', 'do-snippets'): 'yes',
        QName('', 'path'): $path
      }"/>
    </p:xslt>


    <!-- <p:store name="store-page" href="{$target}"
             serialization="map{'method': 'xml', 
                                'indent': true()}"/> -->
                                
    <!-- <p:identity name="entry">
      <p:with-input>
        <p:pipe step="render" />
      </p:with-input>
    </p:identity> -->

    <!-- Second harvest: one sitemap entry per document. Built from the
         variables rather than from the rendered page, so it does not care
         what the page stylesheet did. -->

    <p:variable name="title" as="xs:string"
                select="normalize-space(string((/m:post/m:head/m:title)))">
      <p:pipe step="transform"/>
    </p:variable>

    <p:variable name="created_at" as="xs:string"
                select="normalize-space(string((/m:post/m:head/m:created_at)))">
      <p:pipe step="transform"/>
    </p:variable>

    <p:variable name="updated_at" as="xs:string"
                select="normalize-space(string((/m:post/m:head/m:updated_at)))">
      <p:pipe step="transform"/>
    </p:variable>

    <p:variable name="lastmod" as="xs:string"
                select="format-dateTime(xs:dateTime($updated_at), '[Y0001]-[M01]-[D01]')">
      <p:pipe step="transform"/>
    </p:variable>

    <!-- intro.md -> intro.html, kept relative so it can serve as both the
         on-disk name and the public path in the sitemap. -->
    <!-- <p:variable name="path" as="xs:string"
                select="concat(replace(replace($href, '^.*/', ''),
                                       '\.(md|markdown|mdown)$', ''),
                               '.html')"/> -->

    <p:identity name="entry">
      <p:with-input>
        <p:inline exclude-inline-prefixes="p c cx xs xhtml">
          <m:entry path="{$path}" source="{$href}" created_at="{$created_at}" updated_at="{$updated_at}" lastmod="{$lastmod}"
                   stored="{$target}">{$title}</m:entry>
        </p:inline>
      </p:with-input>
    </p:identity>

  </p:for-each>

  <p:wrap-sequence wrapper="m:sitemap" name="collected">
    <p:with-input pipe="entries@convert"/>
  </p:wrap-sequence>

  <p:xslt name="sitemap">
    <p:with-input port="stylesheet" href="sitemap.xsl"/>
    <p:with-option name="parameters"
                   select="map{ QName('', 'base-url'): $base-url }"/>
  </p:xslt>

  <p:store name="store-sitemap"
           href="{resolve-uri($sitemap-name, $output-dir)}"
           serialization="map{'indent': true()}"/>


  <p:wrap-sequence wrapper="m:snippets" name="snippets">
    <p:with-input pipe="snippets@convert"/>
  </p:wrap-sequence>

  <p:xslt name="home">
    <p:with-input port="stylesheet" href="home.xsl"/>
    <p:with-input port="source"><p:pipe step="snippets"/></p:with-input>
    <p:with-option name="parameters"
                   select="map{ QName('', 'base-url'): $base-url }"/>
  </p:xslt>

  <p:store name="store-home"
           href="{resolve-uri('index.html', $output-dir)}"
           serialization="map{'method': 'html', 'html-version': '5',
                                'indent': true()}"/>

  <p:identity name="fin">
    <p:with-input>
      <p:pipe step="snippets" />
    </p:with-input>
  </p:identity>


</p:declare-step>