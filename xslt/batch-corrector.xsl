<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:scx="http://blackmesatech.com/2020/ns/scx"
		xmlns:xf="http://www.w3.org/2002/xforms"
		xmlns:xsd="http://www.w3.org/2001/XMLSchema"
		xmlns:ev="http://www.w3.org/2001/xml-events"		
		exclude-result-prefixes="xf xsd ev"
		version="3.0">

  <!--* batch-corrector.xsl:  batch corrector for XML (for scx framework).
      *
      * Quick and dirty stylesheet to produce adequate corrections.
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
      * 2023-07-10 : CMSMcQ : renamed from bcx.xsl
      * 2020-04-09 : CMSMcQ : began transform 
      *-->

  <!--****************************************************************
      * 1 Initializetion, setup. 
      ****************************************************************-->
  
  <xsl:output method="xml"
	      indent="yes"
	      />

  <xsl:strip-space elements="*"/>

  <xsl:variable name="xhns"
		select=" 'http://www.w3.org/1999/xhtml' "/>
  <xsl:variable name="scxns"
		select=" ' http://blackmesatech.com/2020/ns/scx' "/>


  <xsl:param name="corrections-file" as="xsd:string" required="yes"/>
  <xsl:param name="corrections" as="element(scx:flaglist)"
	     select="document($corrections-file)/scx:flaglist"/>
		
  <!--****************************************************************
      * 2 Document root, default identity transform
      ****************************************************************-->
  <xsl:template match="/">
    <!--* first do the main input *-->
    <xsl:apply-templates/>
    <!--* then write out the list of dictionary additions *-->
    <xsl:result-document href="../data/corrections.asc"
			 method="text">
      <xsl:variable name="forms-to-add" as="xsd:string*"
		    select="$corrections
			    /descendant::scx:*[@action='add']
			    /scx:w,
			    $corrections
			    /descendant::scx:*[@action='addlc']
			    /scx:w/lower-case(.)"/>
      <xsl:for-each select="distinct-values($forms-to-add)">
	<xsl:sort/>
	<xsl:value-of select="concat(., '&#xA;')"/>
      </xsl:for-each>
    </xsl:result-document>
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
      * 4 scx:* rules for corrections 
      ****************************************************************-->

  <xsl:template match="scx:flag[ancestor::scx:doc]">
    <xsl:variable name="id" as="xsd:string" select="@id"/>
    <xsl:variable name="correction" as="element(scx:flag)"
		  select="$corrections/descendant::scx:flag[@id=$id]"/>

    <xsl:variable name="action" as="xsd:string"
		  select="($correction/parent::scx:w/@action,
			  $correction/@action)[1]"/>
    <xsl:variable name="w" as="xsd:string"
		  select="($correction/parent::scx:wordform/scx:w,
			  $correction/scx:w)[1]"/>
    
    <xsl:choose>
      <xsl:when test="$action = ('add', 'addlc')">
	<!--* to be added to dictionary.  No correction needed. *-->
	<xsl:copy-of select="scx:w"/>
      </xsl:when>
      <xsl:when test="$action = ('accept', 'accept1x')">
	<!--* Not to be added to dictionary, but not changed.
	    * No correction needed. *-->
	<xsl:copy-of select="scx:w"/>
      </xsl:when>
      <xsl:when test="$action = ('sic')">
	<!--* Not to be added to dictionary, but not changed.
	    * No correction needed.  But to be marked as
	    * non-checkable.  *-->
	<scx:w>
	  <xsl:sequence select="scx:w/@*"/>
	  <xsl:attribute name="scx:note" select="'non-checkable'"/>
	  <xsl:sequence select="scx:w/node()"/>
	</scx:w>
	<!--* Q.  Why does the exclude-result-prefixes attribute on
	    * the root element not deal with these prefixes?
	    *-->
      </xsl:when>
      <xsl:when test="$action = ('replace')">
	<!--* To be changed. *-->
	<scx:w>
	  <xsl:sequence select="scx:w/@*"/>
	  <xsl:value-of select="$w"/>
	</scx:w>
      </xsl:when>      
    </xsl:choose>
    
  </xsl:template>

  
</xsl:stylesheet>
