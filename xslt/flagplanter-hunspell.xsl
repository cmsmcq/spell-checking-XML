<!DOCTYPE xsl:stylesheet [
<!ENTITY lsquo  "&#x2018;" ><!--=single quotation mark, left-->
<!ENTITY rsquo  "&#x2019;" ><!--=single quotation mark, right-->
<!ENTITY ldquo  "&#x201C;" ><!--=double quotation mark, left-->
<!ENTITY rdquo  "&#x201D;" ><!--=double quotation mark, right-->
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:scx="http://blackmesatech.com/2020/ns/scx"
		xmlns:xsd="http://www.w3.org/2001/XMLSchema"
		version="3.0">

  <!--* flagplanter-hunspell.xsl:  read Hunspell output and plant flags
      * in a tokenized document (output of *-tokenizer.xsl).
      *
      * Expected usage:
      * 1 xslt input.xml chalmers-tokenizer.xsl tokenized.xml
      * 2 (echo '!'; cat tokenized.xml) | hunspell -d en_GB -a -X \
      *   > hunspell-report.asc 
      * or alternatively
      * 2 cat tokenized.xml | hunspell -d en_GB -a -X | grep '^[&#]' \
      *   > hunspell-report.asc 
      * 3 xslt tokenized.xml hunspell-ingestion.xsl flagged.xml report=hunspell-report.asc
      *
      * Quick and dirty stylesheet to produce adequate results.
      * No attempt will be made at generality, though I believe this
      * ought to work for ispell and aspell as well as for hunspell.
      *-->

  <!--* 
      * Copyright (C) 2020 Black Mesa Technologies LLC
      
      * This program is free software: you can redistribute it and/or
      * modify it under the terms of the GNU General Public License as
      * published by the Free Software Foundation, either version 3 of
      * the License, or (at your option) any later version.
      
      * This program is distributed in the hope that it will be useful,
      * but WITHOUT ANY WARRANTY; without even the implied warranty of
      * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
      * GNU General Public License for more details.
      
      * You should have received a copy of the GNU General Public
      * License along with this program, in the Licenses subdirectory,
      * in file GNU_GPL.
      
      * If the license was not provided, or is missing, see
      * <http://www.gnu.org/licenses/>.
      *-->

  <!--* Revisions:
      * 2023-07-10 : CMSMcQ : rename from hunspell-ingestion.xsl
      * 2020-04-11 : CMSMcQ : assign IDs to flags, suppress flaglist
      * 2020-04-04 : CMSMcQ : adjust xml-stylesheet PI 
      * 2020-04-03 : CMSMcQ : passes Andrews test 
      * 2020-04-02 : CMSMcQ : began transform, running late 
      *                       Work plan:
      *                       . base identity transform 
      *                       . read hunspell report 
      *                       . [WRONG walk report and find bogons in input]
      *                       . process input, find bogons
      *                       . wrap bogons in flag elements
      *-->

  <!--* to do:
      * Q. Would a key help?
      *-->

  <!--****************************************************************
      * 1 Initializetion, setup. 
      ****************************************************************-->

  <xsl:output method="xml"
	      indent="yes"
	      />

  <xsl:strip-space elements="*"/>
  
  <xsl:variable name="scxns"
		as="xsd:string"
		select=" 'http://blackmesatech.com/2020/ns/scx' "/>

  <xsl:variable name="reNearMisses" as="xsd:string"
		select=" '^&amp; ([^ ]+) (\d+) (\d+): (.*)$' "/>
  
  <xsl:variable name="reNoIdeas" as="xsd:string"
		select=" '^# ([^ ]+) (\d+)$' "/>
  

  <!--****************************************************************
      * 1.b Read batch spell checker report
      ****************************************************************-->

  <xsl:param name="report" as="xsd:string" select=" 'hunspell-report.asc' "/>  

  <xsl:variable name="report-uri" as="xsd:string*"
		select="resolve-uri($report, document-uri(/))"/>
  
  <xsl:variable name="lsFlags" as="xsd:string*"
		select="unparsed-text-lines($report-uri)"/>
    
  <xsl:variable name="screport" as="element(scx:flaglist)">
    <xsl:element name="scx:flaglist">
      <xsl:element name="scx:source"><xsl:value-of select="$report-uri"/></xsl:element>
      <xsl:element name="scx:flags">
	<xsl:attribute name="count" select="count($lsFlags)"/>
	<xsl:for-each select="$lsFlags">
	  <xsl:element name="scx:flag">
	    <xsl:attribute name="src" select=" 'hunspell' "/>
	    <xsl:element name="scx:raw"><xsl:value-of select="."/></xsl:element>
	    <xsl:choose>
	      <xsl:when test="matches(.,'^&amp; ')">
		<!--* near misses found, suggestions made *-->
		<xsl:variable name="bogon" as="xsd:string"
			      select="replace(., $reNearMisses, '$1')"/>
		<xsl:variable name="count" as="xsd:integer"
			      select="xsd:integer(replace(., $reNearMisses, '$2'))"/>
		<xsl:variable name="sSuggestions" as="xsd:string"
			      select="replace(., $reNearMisses, '$4')"/>
		<xsl:variable name="lsSuggestions" as="xsd:string+"
			      select="tokenize($sSuggestions, ',\s+')"/>
		<xsl:if test="count($lsSuggestions) ne $count">
		  <xsl:message>Expected <xsl:value-of select="$count"/>, got <xsl:value-of select="count($lsSuggestions)"
		  />:</xsl:message>
		  <xsl:message><xsl:value-of select="."/></xsl:message>
		</xsl:if>
		
		<xsl:element name="scx:bogon">
		  <xsl:value-of select="$bogon"/>
		</xsl:element>
		<xsl:for-each select="$lsSuggestions">
		  <xsl:element name="scx:alt">
		    <xsl:value-of select="."/>
		  </xsl:element>
		</xsl:for-each>
	      </xsl:when>
	      <xsl:when test="matches(.,'^# ')">
		<!--* not in dictionary, no near misses, no suggestions made *-->
		<xsl:variable name="bogon" as="xsd:string"
			      select="replace(., $reNoIdeas, '$1')"/>
		<xsl:element name="scx:bogon">
		  <xsl:value-of select="$bogon"/>
		</xsl:element>
	      </xsl:when>
	      <xsl:otherwise>
		<!--* not a line we worry about *-->
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:element>
	</xsl:for-each>
      </xsl:element>
    </xsl:element>
  </xsl:variable>
  
  <!--****************************************************************
      * 2 Document root
      ****************************************************************-->
  
  <xsl:template match="/">
    <xsl:apply-templates select="/processing-instruction()"/>
    <xsl:element name="scx:flagged-document">
      <!--
	  <xsl:copy-of select="$screport"/>
      -->
      <xsl:element name="scx:doc">
	<xsl:apply-templates select="/*"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="processing-instruction()[name() = 'xml-stylesheet']">
    <xsl:processing-instruction name="xml-stylesheet">
      <xsl:value-of select=" 'type=&quot;text/xsl&quot; href=&quot;../src/flagged-chalmers-html.xsl&quot; '"/>
    </xsl:processing-instruction>
  </xsl:template>
  
  <!--****************************************************************
      * 3 Default identity transform
      ****************************************************************-->

  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:if test="self::element() and not(parent::*)">
	<xsl:attribute name="scx:date" select="current-dateTime()"/>
      </xsl:if>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  

  <!--****************************************************************
      * 4 Tokens
      ****************************************************************-->
  <xsl:template match="scx:w[. = $screport//scx:bogon]
		       |scx:wpc[. = $screport//scx:bogon]">
    <xsl:variable name="n" as="xsd:string">
      <xsl:number level="any" format="001"/>
    </xsl:variable>
    <xsl:variable name="id" as="xsd:string" select="concat('f-', $n)"/>
   
    <xsl:variable name="this"
		  as="xsd:string"
		  select="string()"/>
    <xsl:variable name="flag"
		  as="element(scx:flag)"
		  select="($screport//scx:bogon[. = $this]
			  /parent::scx:flag)[1]"/>
    <xsl:element name="scx:flag">
      <xsl:attribute name="id" select="$id"/>
      <xsl:sequence select="$flag/@*"/>
      <xsl:copy-of select="."/>
      <xsl:sequence select="$flag/*"/>      
    </xsl:element>
  </xsl:template>
  
  <!--****************************************************************
      * 5 Phrase-level elements
      ****************************************************************-->
 

  <!--****************************************************************
      * 6 Footnotes and hypertext
      ****************************************************************-->

  <!--****************************************************************
      * 7 Special cases
      ****************************************************************-->
  
</xsl:stylesheet>
