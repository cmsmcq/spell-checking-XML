<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:scx="http://blackmesatech.com/2020/ns/scx"
		xmlns:xf="http://www.w3.org/2002/xforms"
		xmlns:xsd="http://www.w3.org/2001/XMLSchema"
		xmlns:ev="http://www.w3.org/2001/xml-events"		
		version="3.0">

  <!--* flaggedxml-to-xform.xsl: convert flagged Chalmers data into
      * an Xform using XHTML as the host language.
      *
      * Quick and dirty stylesheet to produce adequate form.
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
      * 2023-07-10 : CMSMcQ : Rename from flagged-chalmers-html.xsl
      *                       (but not yet general-purpose).
      * 2020-07-06 : CMSMcQ : group flags by form in the flaglist, so 
      *                       we can handle 'accept' and 'add to
      *                       dictionary' correctly.
      * 2020-07-06 : CMSMcQ : change display of page elements to make 
      *                       them easier to find and click on. 
      * 2020-04-07 : CMSMcQ : choose a v0.1 widget style and go
      * 2020-04-04 : CMSMcQ : began transform 
      *-->

  <!--****************************************************************
      * 1 Initializetion, setup. 
      ****************************************************************-->

  <xsl:import href="chalmers-html.xsl"/>
  
  <xsl:output method="xhtml"
	      indent="yes"
	      html-version="5.0"
	      />

  <xsl:strip-space elements="*"/>

  <xsl:variable name="xhns"
		select=" 'http://www.w3.org/1999/xhtml' "/>
  <xsl:variable name="scxns"
		select=" ' http://blackmesatech.com/2020/ns/scx' "/>

  <!--* Some characters we might want *-->
  <xsl:variable name="ch-checkmark0" as="xsd:string"
		select=" '&#x2713;' "/>
  <xsl:variable name="ch-checkmark" as="xsd:string"
		select=" '&#x2714;' "/>
  <xsl:variable name="ch-caret" as="xsd:string"
		select=" '&#x2041;' "/>
  <xsl:variable name="ch-cycle" as="xsd:string"
		select=" '&#x21BB;' "/>
  <xsl:variable name="ch-ballot-x" as="xsd:string"
		select=" '&#x2718;' "/>
  <xsl:variable name="ch-redpennant" as="xsd:string"
		select=" '&#x1F6A9;' "/>
  <xsl:variable name="ch-blackflag" as="xsd:string"
		select=" '&#x2691;' "/>
  <xsl:variable name="ch-whiteflag" as="xsd:string"
		select=" '&#x2690;' "/>
  
  <!--****************************************************************
      * 2 Document root
      ****************************************************************-->
  <xsl:template match="/">
    <xsl:if test="empty(//scx:flag)">
      <xsl:message terminate="yes">No spelling flags found, no point in generating XForm.  Bye.</xsl:message>
    </xsl:if>

    <!--* The scx:flaglist element belongs in the model, but we
	* also need to consult it when building the switch elements
	* in the body of the form.  So we put it into a variable
	* so we can pass it around and consult it.
	*-->
    <xsl:variable name="e-flaglist" as="element(scx:flaglist)">
      <xsl:element name="scx:flaglist">
	<xsl:copy-of
	    select="/scx:flagged-document/scx:flaglist/scx:source"/>	      
	<xsl:call-template name="flags-in-model"/>
      </xsl:element>
    </xsl:variable>
    
    <xsl:processing-instruction name="xml-stylesheet">
      <xsl:text>type="text/xsl" href="../../lib/xsltforms/xsltforms.xsl"</xsl:text>
    </xsl:processing-instruction>
    <xsl:element name="html" namespace="{$xhns}">
      <xsl:attribute name="scx:label" select=" 'Spell checking for XML:  prototype v0' "/>
      <xsl:attribute name="xf:dummy" select=" 'XForms 1.1' "/>
      <xsl:attribute name="xsd:dummy" select=" 'XML Schema Definition Language 1.1' "/>
      <xsl:attribute name="ev:dummy" select=" 'XML Events' "/>
      <xsl:element name="head" namespace="{$xhns}">
	<xsl:element name="title" namespace="{$xhns}">
	  <xsl:apply-templates select="descendant::title[1]" mode="htmltitle"/>
	  <!--
	  <xsl:value-of
	  select="normalize-space(/descendant::title[1])"/>
	  -->
	  <!--* letter/title or entry/title *-->
	</xsl:element>

	<xsl:element name="xf:model">
	  <xsl:attribute name="id" select=" 'xf-model' "/>
	  <xsl:element name="xf:instance">
	    <xsl:attribute name="id" select=" 'flaglist' "/>
	    <xsl:sequence select="$e-flaglist"/>	    
	  </xsl:element>	    
	  <xsl:call-template name="actions-in-model">
	    <xsl:with-param name="e-flaglist"
			    select="$e-flaglist"
			    tunnel="yes"/>
	  </xsl:call-template>
	</xsl:element>

	<xsl:call-template name="std-css-block"/>
	<xsl:call-template name="xforms-css-block"/>
	
      </xsl:element>
      <xsl:element name="body" namespace="{$xhns}">
	<xsl:apply-templates>
	  <xsl:with-param name="e-flaglist"
			  select="$e-flaglist"
			  tunnel="yes"/>
	</xsl:apply-templates>
	<xsl:call-template name="orphaned-notes">
	    <xsl:with-param name="e-flaglist"
			    select="$e-flaglist"
			    tunnel="yes"/>
	</xsl:call-template>
	<xsl:call-template name="show-instance"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>  

  
  <!--****************************************************************
      * 3 Coarse document structure
      ****************************************************************-->

  <xsl:template match="entry/title" mode="htmltitle">
    <xsl:value-of select="string-join(for $w in descendant::scx:w return string($w), ' ')"/>
  </xsl:template>
  
  <xsl:template match="scx:flagged-document">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="scx:flaglist"/>
  
  <xsl:template match="scx:doc">
    <xsl:apply-templates/>
  </xsl:template>
 

  <!--****************************************************************
      * 4 scx:* rules for corrections list (XForms instance)
      ****************************************************************-->

  <!--* flags-in-model:  for each distinct form in the flags, make
      * an scx:form element, containing the flags.
      *-->
  <xsl:template name="flags-in-model">
    <xsl:for-each-group
	select="/scx:flagged-document/scx:doc//scx:flag"
	group-by="scx:bogon/string()">
      <xsl:element name="scx:wordform">
	<xsl:attribute name="id" select=" concat('wordform-', current-group()[1]/@id) "/>
	<xsl:attribute name="action" select=" 'undecided' "/>
	<xsl:sequence select="current-group()[1]/(scx:bogon, scx:alt,
			      scx:raw)"/>
	<xsl:apply-templates select="current-group()"
			     mode="wordform-flags"/>
      </xsl:element>
    </xsl:for-each-group>
  </xsl:template>


  <xsl:template match="scx:flag" mode="wordform-flags">
    <xsl:copy>
      <xsl:sequence select="@id"/>
      <xsl:attribute name="action" select=" 'follow-wordform' "/>
      <!-- by default, the flag is handled however the form as a whole 
	   is handled -->
      <xsl:sequence select="@* except @id"/>
      <xsl:copy-of select="scx:w"/>
      <xsl:sequence select="scx:bogon"/>
    </xsl:copy>
    
    <xsl:if test="string(scx:bogon) ne string(scx:w)">
      <xsl:message>bogon ne word!  <xsl:copy-of select="scx:bogon"/> vs <xsl:copy-of select="scx:w"/></xsl:message>
    </xsl:if>
  </xsl:template>

  <!--* actions-in-model:  for each distinct form in the flags, make
      * an xf:action element, containing actions for marking every
      * token of a type as decided.  (At least, do this if there is
      * more than one flag for the form.  If there is only one, don't
      * bother.)
      *
      * N.B. Once a form has been accepted, reconsideration occurs
      * token by token, not form by form.
      *-->
  <xsl:template name="actions-in-model">
    <xsl:param name="e-flaglist"
	       tunnel="yes"
	       as="element(scx:flaglist)"/>
    
    <xsl:for-each select="$e-flaglist/scx:wordform">
      <xsl:if test="count(scx:flag) gt 1">
	<xsl:element name="xf:action">
	  <xsl:attribute name="ev:event"
			 select=" concat('scx:decide-form-',
				 child::scx:flag[1]/@id,
				 '-et-al') "/>
	  <xsl:for-each select="scx:flag">
	    <xsl:element name="xf:toggle">
	      <xsl:attribute name="case"
			     select="concat('decided-',
				     ./@id)"/>
	    </xsl:element>
	  </xsl:for-each>
	</xsl:element>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  

  <!--****************************************************************
      * 5 scx:* rules for document display 
      * 5 Phrase-level elements
      ****************************************************************-->

  <!--* Space in native XML becomes space in HTML *-->
  <xsl:template match="scx:s">
    <xsl:choose>
      <xsl:when test="contains(., '10')">
	<xsl:text>&#xA;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text> </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--* Punctuation is carried through. *-->
  <xsl:template match="scx:pc">
    <xsl:apply-templates/>
  </xsl:template>
  
  <!--* Normal words are carried through. *-->
  <xsl:template match="scx:w|scx:wpc">
    <xsl:apply-templates/>
  </xsl:template>

  <!--* Flagged words turn into a paired xf:output and xf:switch: the
      * first for display in the running text, the second for floating
      * the correction widget over to the right.
      * (Actually, we should do them in the other order: float first.)
      *-->

  <xsl:template match="scx:flag">
    <!--* The e-flaglist parameter provides the main part of the
	* XForms instance, to make it easier to know which toggles
	* to use and which events to fire. *-->
    <xsl:param name="e-flaglist"
	       tunnel="yes"
	       required="yes"
	       as="element(scx:flaglist)"/>

    <!--* $id is the id of this flag element *-->
    <xsl:variable name="id" as="xsd:string" select="@id"/>

    <!--* $instance-flag is the image of this flag element, in the 
	* XForm instance *-->    
    <xsl:variable name="instance-flag"
		  as="element(scx:flag)"
		  select="$e-flaglist/scx:wordform/scx:flag[@id eq $id]"/>    

    <!--* $accept-action is the action to fire when the user decides
	* to accept the word form or add it to the dictionary. *-->
    <xsl:variable name="accept-action"
		  as="element()">
      <xsl:choose>
	<!--* If there is only one token for this word form [only 
	    * one flag in the parent scx:wordform element], then 
	    * just toggle the current switch; no need to get fancy. 
	    *-->
	<xsl:when test="count($instance-flag/parent::*/scx:flag)
			eq 1">
	  <xf:toggle case="decided-{$id}" />
	</xsl:when>
	<!--* If there is more than one token for this word form,
	    * we could repeat all the toggle actions, but it seems
	    * cleaner to package it as an action in the model.  So
	    * what we need to do is fire an event named
	    * scx:decide-form-{$id1}-et-al (where $id1 is the first
	    * flag id in the form)
	    *-->
	<xsl:otherwise>
	  <xsl:variable name="id1"
			select="$instance-flag/parent::scx:wordform
				/scx:flag[1]/@id"/>
	  <xf:dispatch name="scx:decide-form-{$id1}-et-al"
		       targetid="xf-model"
		       />
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!--* First the widget for user interaction, which floats. *-->
    <xf:switch ref="scx:wordform/scx:flag[@id='{$id}']" class="flag">

      <!--* We have four states/cases:  undecided (the initial state),
	  * accepting, changing, and decided. *-->
      <!--* We decide a case by accepting the form or changing it.  So
	  * the undecided state has two buttons. *-->
      <xf:case id="undecided-{$id}">
	<xf:label class="bogon"><xsl:value-of select="scx:bogon" /></xf:label>
	<xf:trigger>
	  <xf:label>Accept</xf:label>
	  <xf:toggle case="accepting-{$id}" ev:event="DOMActivate"/>
	</xf:trigger>
	<xf:trigger>
	  <xf:label>Change</xf:label>
	  <xf:toggle case="changing-{$id}" ev:event="DOMActivate"/>
	</xf:trigger>
      </xf:case>

      <!--* We have several different ways to accept a form:
	  * permanent or temporary (or just this once), as-is or
	  * lowercased.  Marking it non-checkable is a form of
	  * acceptance, too.  If we have second thoughts or got here 
	  * by mistake we can cancel.
	  *
	  * Accepting once and marking as non-checkable affect
	  * just this one token, so they change @action on the
	  * flag itself.
	  *
	  * All other forms of acceptance affect the word form (and
	  * thus all other occurrences, too), so they change @action
	  * on the containing scx:wordform element.
	  *-->
      <xf:case id="accepting-{$id}">
	<xf:label>Accept <xsl:value-of select="scx:bogon"/></xf:label>
	<xf:trigger>
	  <xf:label>Add &#x201C;<xsl:value-of select="scx:bogon"
	  />&#x201D; to dictionary</xf:label>
	  <xf:action ev:event="DOMActivate">
	    <xf:setvalue ref="parent::scx:wordform/@action" value="'add'" />
	    <xsl:sequence select="$accept-action"/>
	  </xf:action>
	</xf:trigger>
	<xsl:if test="string(scx:bogon) ne lower-case(scx:bogon)">
	  <xf:trigger>
	    <xf:label>Add &#x201C;<xsl:value-of
	    select="lower-case(scx:bogon)"
	    />&#x201D; (lower-case)</xf:label>
	    <xf:action ev:event="DOMActivate">
	      <xf:setvalue ref="parent::scx:wordform/@action"
			   value="'addlc'" />
	      <xsl:sequence select="$accept-action"/>
	    </xf:action>
	  </xf:trigger>
	</xsl:if>
	<xf:trigger>
	  <!-- <xf:label>Accept &#x201C;<xsl:value-of select="scx:bogon"/>&#x201D; for this session</xf:label> -->
	  <xf:label>Accept for session</xf:label>
	  <xf:action ev:event="DOMActivate">
	    <xf:setvalue ref="parent::scx:wordform/@action" value="'accept'" />
	    <xsl:sequence select="$accept-action"/>
	  </xf:action>
	</xf:trigger>
	<xf:trigger>
	  <!-- <xf:label>Accept &#x201C;<xsl:value-of select="scx:bogon"/>&#x201D; here</xf:label> -->
	  <xf:label>Accept here</xf:label>
	  <xf:action ev:event="DOMActivate">
	    <xf:setvalue ref="@action" value="'accept1x'" />
	    <xf:toggle case="decided-{$id}" />
	  </xf:action>
	</xf:trigger>
	<xf:trigger>
	  <xf:label>Mark as non-checkable</xf:label>
	  <xf:action ev:event="DOMActivate">
	    <xf:setvalue ref="@action" value="'sic'" />
	    <xf:toggle case="decided-{$id}" />
	  </xf:action>
	</xf:trigger>
	<xsl:element name="hr" namespace="{$xhns}"/>
	<xf:trigger>
	  <xf:label>Cancel</xf:label>
	  <xf:setvalue ref="@action" value=" 'undecided' "/>
	  <xf:toggle case="undecided-{$id}" ev:event="DOMActivate"/>
	</xf:trigger>
      </xf:case>

      <!--* To change the form, the user may accept a suggestion
	  * or may type in the correct spelling.  Changing always affects
	  * only the current token; we don't have global corrections.
	  * (We could, if we wanted to.)
	  *-->
      <xf:case id="changing-{$id}">
	<xf:label class="accepting">Change <xsl:value-of select="scx:bogon"/> to:</xf:label>
	<xf:input ref="scx:w" incremental="true">
	  <xf:label/>
	</xf:input>    
	<xf:trigger>
	  <xf:label>Change to &#x201C;<xf:output ref="scx:w"/>&#x201D;</xf:label>
	  <xf:action ev:event="DOMActivate">
	    <xf:setvalue ref="@action" value=" 'replace' "/>
	    <xf:setvalue ref="@status" value="'decided'"/>
	    <xf:toggle case="decided-{$id}"/>
	  </xf:action>
	</xf:trigger>
	<xsl:for-each select="scx:alt">
	  <xf:trigger>
	    <xf:label>Change to &#x201C;<xsl:value-of select="."/>&#x201D;</xf:label>
	    <xf:action ev:event="DOMActivate">
	      <xf:setvalue ref="@action" value=" 'replace' "/>
	      <xf:setvalue ref="scx:w" value=" '{scx:munge(.)}' "/>
	      <xf:toggle case="decided-{$id}"/>
	    </xf:action>
	  </xf:trigger>
	</xsl:for-each>	
	<xsl:element name="hr" namespace="{$xhns}"/>
	<xf:trigger>
	  <xf:label>Cancel</xf:label>
	  <xf:setvalue ref="@action" value=" 'undecided' "/>
	  <xf:toggle case="undecided-{$id}" ev:event="DOMActivate"/>
	</xf:trigger>	
      </xf:case>
      
      <xf:case id="decided-{$id}">
	<xf:trigger>
	  <xf:label class="bogon"><xsl:value-of select="concat(scx:bogon, ' ', $ch-cycle)"/></xf:label>
	  <xf:action ev:event="DOMActivate">
	    <xf:setvalue ref="@action" value="'undecided'" />
	    <xf:setvalue ref="scx:w" value="string(../scx:bogon)" />
	    <xf:toggle case="undecided-{$id}" />
	  </xf:action>
	</xf:trigger>
      </xf:case>
      
    </xf:switch>
    
    <!--* Second, the inline version of the word, with an output element. *-->
    <!--* Actually, we emit several output elements, to enable different
	* displays of the word.  And because we want (a) to minimize the
	* number of elements XSLTForms has to search for, and (b) to include
	* additional material that is only conditionally visible, we
	* wrap them all in groups.
	*-->

    <xf:group ref="scx:wordform/scx:flag[@id='{$id}']" class="flagged">
      <!--* The first several alternatives are for flags with
	  * @action = 'follow-wordform' and branch on the value
	  * of the parent word form's action attribute.
	  * So we wrap them in a group.
	  *-->
      <xf:group ref=".[@action='follow-wordform']">
	<!--* First form:  undecided, class flagged-token *-->
	<!--* Sample rendering:  wavy red underline *-->
	<xf:group ref=".[parent::scx:wordform/@action='undecided']">
	  <xf:output value="scx:w" class="inline flagged-token"/>
	</xf:group>
    
	<!--* Second form:  added to dictionary ('add' or 'addlc') *-->
	<!--* Sample rendering:  wavy green underline, following green checkmark *-->
	<xf:group ref=".[starts-with(parent::scx:wordform/@action, 'add')]">
	  <!--* action = ('add', 'addlc') *-->
	  <xf:output value="scx:w" class="inline added"/>
	</xf:group>
      
	<!--* Third form:  accepted but not added to dictionary *-->
	<!--* Sample rendering:  wavy gray underline, following [stet] *-->
	<xf:group ref=".[parent::scx:wordform/@action = 'accept']">
	  <xf:output value="scx:w" class="inline stet"/>
	</xf:group>
      </xf:group>
      
      
      <!--* Third form (second time around):  accepted here only *-->
      <!--* Sample rendering:  wavy gray underline, following [stet] *-->
      <xf:group ref=".[@action = 'accept1x']">
	<xf:output value="scx:w" class="inline stet"/>
      </xf:group>
      
      <!--* Fourth form:  marked as not checkable *-->
      <!--* Sample rendering:  wavy gray underline, following [sic] *-->
      <xf:group ref=".[@action='sic']">
      <xf:output value="scx:w" class="inline sic"/>
      </xf:group>

      <!--* Fifth form:  changed *-->
      <!--* Sample rendering:  wavy red underline plus line through,
	  * followed by insertion mark U+2041 and new form
	  *-->
      <xf:group ref=".[@action='replace']">
	<xf:output value="scx:bogon" class="inline changed"/>
	<xf:output value="scx:w" class="inline newval"/>
      </xf:group>
    </xf:group>
    
  </xsl:template>  
  
  
  <!--****************************************************************
      * 6 Footnotes and hypertext
      ****************************************************************-->
  <xsl:template match="page">
    <xsl:variable name="imageref">
      <xsl:value-of
	  select="concat('http://words.fromoldbooks.org/i/c/',
		  @vol,
		  string(),
		  '.png')"/>
    </xsl:variable>
    <xsl:element name="a" namespace="{$xhns}">
      <xsl:attribute name="class"><xsl:value-of select="name()"/></xsl:attribute>
      <xsl:attribute name="title">Open page-scan</xsl:attribute>
      <xsl:attribute name="href"><xsl:value-of select="$imageref"/></xsl:attribute>
      <xsl:attribute name="target"><xsl:value-of select="'pagescan'"/></xsl:attribute>
      <xsl:element name="span" namespace="{$xhns}">
	<xsl:attribute name="class"><xsl:value-of select="name()"/></xsl:attribute>
	<xsl:element name="span" namespace="{$xhns}">
	  <xsl:attribute name="class">volnum</xsl:attribute>
	  <xsl:value-of select="@vol"/>
	</xsl:element>
	<xsl:text>|</xsl:text>
	<xsl:element name="span" namespace="{$xhns}">
	  <xsl:attribute name="class">pagenum</xsl:attribute>
	  <xsl:apply-templates/>
	</xsl:element>
      </xsl:element>
    </xsl:element>
  </xsl:template>


  <!--****************************************************************
      * 7 Special cases
      ****************************************************************-->

  <xsl:template name="show-instance">
    <xsl:element name="hr" namespace="{$xhns}"/>
    <xf:switch ref="instance(flaglist)">
      <xf:case id="hidexml">
	<xf:trigger>
	  <xf:label>Show XML of corrections list</xf:label>
	  <xf:toggle case="showxml" ev:event="DOMActivate"/>
	</xf:trigger>
      </xf:case>
      <xf:case id="showxml">
	<xsl:element name="p" namespace="{$xhns}">
	  <xsl:text>Now select the entire XML document and save to disk.</xsl:text>
	</xsl:element>
	<xf:trigger>
	  <xf:label>Hide XML</xf:label>
	  <xf:toggle case="hidexml" ev:event="DOMActivate"/>
	</xf:trigger>
	<xsl:element name="div" namespace="{$xhns}">
	  <xsl:attribute name="class" select="'dump'"/>
	  <xsl:element name="pre" namespace="{$xhns}">
	    <xsl:attribute name="class" select="'dump'"/>
	    <xsl:element name="xf:output">
	      <xsl:attribute name="class" select=" 'dump' "/>
	      <xsl:attribute name="mediatype" select=" 'text/html' "/>
	      <xsl:attribute name="value" select=" 'transform(., &quot;../../lib/prettyprint.xsl&quot;, false)' "/>
	    </xsl:element>
	  </xsl:element>
	</xsl:element>
	<xf:trigger>
	  <xf:label>Hide XML</xf:label>
	  <xf:toggle case="hidexml" ev:event="DOMActivate"/>
	</xf:trigger>
      </xf:case>
    </xf:switch>
  </xsl:template>


  <!--****************************************************************
      * 8 CSS 
      ****************************************************************-->
  <!--* moved the CSS here to get it out of the way *-->
  <!--* std-css-block is what the user stylesheet had. *-->
  <xsl:template name="std-css-block">
	
    <xsl:element name="style" namespace="{$xhns}">
      <xsl:attribute name="type">text/css</xsl:attribute>
      
      <xsl:text>         div.unknown {&#xA;</xsl:text>
      <xsl:text>             color: red;&#xA;</xsl:text>
      <xsl:text>             margin-left: 1em;&#xA;</xsl:text>
      <xsl:text>         }&#xA;</xsl:text>
      
      <xsl:text>         h1.entry-title {&#xA;</xsl:text>
      <xsl:text>             display: inline;&#xA;</xsl:text>
      <xsl:text>         }&#xA;</xsl:text>
      
      <xsl:text>         span.csc, span.sc {&#xA;</xsl:text>
      <xsl:text>             font-variant: small-caps;&#xA;</xsl:text>
      <xsl:text>         }&#xA;</xsl:text>
      
      <xsl:text>         div.p {&#xA;</xsl:text>
      <xsl:text>             margin: 1em 0em;&#xA;</xsl:text>
      <xsl:text>         }&#xA;</xsl:text>

      <xsl:text>         div.fn > div.p {&#xA;</xsl:text>
      <xsl:text>             margin: 0em;&#xA;</xsl:text>
      <xsl:text>         }&#xA;</xsl:text>

      <xsl:text>         div.fn {&#xA;</xsl:text>
      <xsl:text>             background-color:  #DDD;&#xA;</xsl:text>
      <xsl:text>             padding: 0em 1em 0.5em 1em;&#xA;</xsl:text>
      <xsl:text>             margin: 0em 0em 0em 2em;&#xA;</xsl:text>
      <xsl:text>             font-size: small: 2em;&#xA;</xsl:text>
      <xsl:text>         }&#xA;</xsl:text>

      <xsl:text>         div.orphaned-note > div.fn {&#xA;</xsl:text>
      <xsl:text>             border: 1px solid navy;&#xA;</xsl:text>
      <xsl:text>             background-color:  #AEA;&#xA;</xsl:text>
      <xsl:text>             margin: 1em 0em 1em 2em;&#xA;</xsl:text>
      <xsl:text>         }&#xA;</xsl:text>

      <xsl:text>         div.fn span.m {&#xA;</xsl:text>
      <xsl:text>             display: inline-block;&#xA;</xsl:text>
      <xsl:text>             padding-right: 0.3em;&#xA;</xsl:text>
      <xsl:text>         }&#xA;</xsl:text>

      <xsl:text>         a.fr {&#xA;</xsl:text>
      <xsl:text>             display: inline-block;&#xA;</xsl:text>
      <xsl:text>             color: navy;&#xA;</xsl:text>
      <xsl:text>             padding-right: 0.3em;&#xA;</xsl:text>
      <xsl:text>         }&#xA;</xsl:text>

      <xsl:text>         a.page {&#xA;</xsl:text>
      <xsl:text>             display: block;&#xA;</xsl:text>
      <xsl:text>             width: 100%;&#xA;</xsl:text>
      <xsl:text>             background-color: #FEE;&#xA;</xsl:text>
      <xsl:text>             border: 1px dotted #A55;&#xA;</xsl:text>
      <xsl:text>             margin: 0.3em 0em;&#xA;</xsl:text>
      <xsl:text>             text-align: center;&#xA;</xsl:text>
      <xsl:text>             cursor: pointer;&#xA;</xsl:text>
      <xsl:text>         }&#xA;</xsl:text>

      <xsl:text>         span.page {&#xA;</xsl:text>
      <xsl:text>             display: inline-block;&#xA;</xsl:text>
      <xsl:text>             color: #A33;&#xA;</xsl:text>
      <xsl:text>             padding: 0 0.3em;&#xA;</xsl:text>
      <xsl:text>         }&#xA;</xsl:text>

      <xsl:text>         span.page > span.volnum, span.page > span.pagenum {&#xA;</xsl:text>
      <xsl:text>             padding: 0 0.2em;&#xA;</xsl:text>
      <xsl:text>             vertical-align: super;&#xA;</xsl:text>
      <xsl:text>             font-size: x-small;&#xA;</xsl:text>
      <xsl:text>         }&#xA;</xsl:text>

      <xsl:text>         span.source {&#xA;</xsl:text>
      <xsl:text>             font-style: italic;&#xA;</xsl:text>
      <xsl:text>         }&#xA;</xsl:text>

      <xsl:text>         span.q {&#xA;</xsl:text>
      <xsl:text>             color: navy;&#xA;</xsl:text>
      <xsl:text>         }&#xA;</xsl:text>

      <xsl:text>         span.date {&#xA;</xsl:text>
      <xsl:text>             color: #484;&#xA;</xsl:text>
      <xsl:text>         }&#xA;</xsl:text>

      
    </xsl:element>
  </xsl:template>

  
  <!--* xforms-css-block is what we add or change by override. *-->
  <xsl:template name="xforms-css-block">

	<xsl:element name="style" namespace="{$xhns}">
	  <xsl:attribute name="type">text/css</xsl:attribute>
	  <xsl:comment>* XForms-specific styling *</xsl:comment>
	  <xsl:text>&#xA;         @namespace xf "http://www.w3.org/2002/xforms";&#xA;</xsl:text>
	  <xsl:text>         body {&#xA;</xsl:text>
	  <xsl:text>             margin: 1em;&#xA;</xsl:text>
	  <xsl:text>         }&#xA;</xsl:text>
	  <xsl:text>         xf|label {&#xA;</xsl:text>
	  <xsl:text>             font-weight : bold;&#xA;</xsl:text>
	  <xsl:text>             width : 16em;&#xA;</xsl:text>
	  <xsl:text>         }&#xA;</xsl:text>
	  <xsl:text>         invalid ::value {&#xA;</xsl:text>
	  <xsl:text>             background-color : pink;&#xA;</xsl:text>
	  <xsl:text>         }&#xA;</xsl:text>
	  <xsl:text>         /* Special handling for XSLTForms: */&#xA;</xsl:text>
	  <xsl:text>         .xforms-invalid .xforms-value {&#xA;</xsl:text>
	  <xsl:text>             background-color : pink;&#xA;</xsl:text>
	  <xsl:text>         }&#xA;</xsl:text>

	  <xsl:text>         xf|switch.flag {&#xA;</xsl:text>
	  <xsl:text>             float: right;&#xA;</xsl:text>
	  <xsl:text>         	 max-width: 20%;&#xA;</xsl:text>
	  <xsl:text>         	 padding: 0.2em 0.5em;&#xA;</xsl:text>
	  <xsl:text>         	 margin: 0em 0.1em;&#xA;</xsl:text>
	  <xsl:text>         	 border: 1px solid black;&#xA;</xsl:text>
	  <xsl:text>         	 background-color: pink;&#xA;</xsl:text>
	  <xsl:text>         	 vertical-align: top;&#xA;</xsl:text>
	  <xsl:text>         }&#xA;</xsl:text>

	  <xsl:text>         xf|switch xf|trigger {&#xA;</xsl:text>
	  <xsl:text>             display: block;&#xA;</xsl:text>
	  <xsl:text>         }&#xA;</xsl:text>

	  <xsl:text>         xf|group.flagged {&#xA;</xsl:text>
	  <xsl:text>             display: inline-block;&#xA;</xsl:text>
	  <xsl:text>         }&#xA;</xsl:text>
	  
	  <xsl:text>         xf|output.inline {&#xA;</xsl:text>
	  <xsl:text>             background-color: yellow;&#xA;</xsl:text>
	  <xsl:text>             display: inline;&#xA;</xsl:text>
	  <xsl:text>             font-weight: bold; &#xA;</xsl:text>
	  <xsl:text>             text-decoration-line: underline; &#xA;</xsl:text>
	  <xsl:text>             text-decoration-style: wavy; &#xA;</xsl:text>
	  <xsl:text>         }&#xA;</xsl:text>
	  
	  <xsl:text>         xf|output.flagged-token {&#xA;</xsl:text>
	  <xsl:text>             text-decoration-color: red;&#xA;</xsl:text>
	  <xsl:text>         }&#xA;</xsl:text>
	  <xsl:text>         xf|output.flagged-token::after {&#xA;</xsl:text>
	  <xsl:text>             content:  " </xsl:text>
	  <!-- <xsl:value-of select="$ch-redpennant"/> -->
	  <xsl:value-of select="$ch-blackflag"/>
	  <!-- <xsl:value-of select="$ch-ballot-x"/> -->
	  <xsl:text>";&#xA;</xsl:text>
	  <xsl:text>             color: red;&#xA;</xsl:text>
	  <xsl:text>         }&#xA;</xsl:text>
	  
	  <xsl:text>         xf|output.added {&#xA;</xsl:text>
	  <xsl:text>             text-decoration-color: green;&#xA;</xsl:text>
	  <xsl:text>         }&#xA;</xsl:text>
	  <xsl:text>         xf|output.added::after {&#xA;</xsl:text>
	  <xsl:text>             content:  " </xsl:text>
	  <xsl:value-of select="$ch-checkmark"/>
	  <xsl:text>";&#xA;</xsl:text>
	  <xsl:text>             color: green;&#xA;</xsl:text>
	  <xsl:text>         }&#xA;</xsl:text>
	  
	  <xsl:text>         xf|output.stet {&#xA;</xsl:text>
	  <xsl:text>             text-decoration-color: gray;&#xA;</xsl:text>
	  <xsl:text>         }&#xA;</xsl:text>
	  <xsl:text>         xf|output.stet::after {&#xA;</xsl:text>
	  <xsl:text>             content:  " [stet]";&#xA;</xsl:text>
	  <xsl:text>             color: gray;&#xA;</xsl:text>
	  <xsl:text>         }&#xA;</xsl:text>
	  
	  <xsl:text>         xf|output.sic {&#xA;</xsl:text>
	  <xsl:text>             text-decoration-color: black;&#xA;</xsl:text>
	  <xsl:text>             text-decoration-style: double; &#xA;</xsl:text>
	  <xsl:text>         }&#xA;</xsl:text>
	  <xsl:text>         xf|output.sic::after {&#xA;</xsl:text>
	  <xsl:text>             content:  " [sic]";&#xA;</xsl:text>
	  <xsl:text>             color: gray;&#xA;</xsl:text>
	  <xsl:text>         }&#xA;</xsl:text>
	  
	  <xsl:text>         xf|output.changed {&#xA;</xsl:text>
	  <xsl:text>             text-decoration-line: line-through;&#xA;</xsl:text>
	  <xsl:text>             text-decoration-style: solid;&#xA;</xsl:text>
	  <xsl:text>             text-decoration-color: red;&#xA;</xsl:text>
	  <xsl:text>         }&#xA;</xsl:text>
	  <xsl:text>         xf|output.newval {&#xA;</xsl:text>
	  <xsl:text>             text-decoration-style: solid;&#xA;</xsl:text>
	  <xsl:text>         }&#xA;</xsl:text>
	  <xsl:text>         xf|output.newval::before {&#xA;</xsl:text>
	  <xsl:text>             content:  " </xsl:text>
	  <xsl:value-of select="$ch-caret"/>
	  <xsl:text> ";&#xA;</xsl:text>
	  <xsl:text>             text-decoration: none;&#xA;</xsl:text>
	  <xsl:text>         }&#xA;</xsl:text>

	  <xsl:text>         xf|div.dump {&#xA;</xsl:text>
	  <xsl:text>             background-color: #EEE;&#xA;</xsl:text>
	  <xsl:text>             border: 1px solid black;&#xA;</xsl:text>
	  <xsl:text>             padding: 1em;&#xA;</xsl:text>
	  <xsl:text>         }&#xA;</xsl:text>

	  <xsl:text>         xf|output.dump {&#xA;</xsl:text>
	  <xsl:text>             display: block;&#xA;</xsl:text>
	  <xsl:text>         }&#xA;</xsl:text>
	  
	  <xsl:text>&#xA;</xsl:text>
	</xsl:element>
  </xsl:template>

  <xsl:function name="scx:munge" as="xsd:string">
    <xsl:param name="s" as="xsd:string"/>
    <xsl:value-of select="replace($s, &quot;'&quot;, &quot;&amp;apos;&quot;)"/>
  </xsl:function>


  <!--****************************************************************
      * 9 Geniza
      ****************************************************************-->
  <!--* mode xforms-model is now dead code, kept around only
      * for insurance *-->
  <xsl:template match="scx:flag" mode="geniza-xforms-model">
    <!--
    <xsl:variable name="n" as="xsd:string">
      <xsl:number from="scx:doc" level="any" format="001"/>
    </xsl:variable>
    <xsl:variable name="id" as="xsd:string" select="concat('f-', $n)"/>
    -->
    <xsl:copy>
      <!-- <xsl:attribute name="id" select="$id"/> -->
      <xsl:attribute name="action" select=" 'undecided' "/>
      <xsl:sequence select="@*"/>
      <xsl:copy-of select="scx:w"/>
      <!--*
      <xsl:element name="scx:action">
	<xsl:text>do-nothing</xsl:text>
      </xsl:element>
      <xsl:element name="scx:wordform">
	<xsl:value-of select="string(scx:w)"/>
      </xsl:element>
      *-->
      <xsl:sequence select="scx:bogon, scx:alt, scx:raw"/>
    </xsl:copy>
    
    <xsl:if test="string(scx:bogon) ne string(scx:w)">
      <xsl:message>bogon ne word!  <xsl:copy-of select="scx:bogon"/> vs <xsl:copy-of select="scx:w"/></xsl:message>
    </xsl:if>
  </xsl:template>

  <!--* Sample flag:
      * <scx:flag id="f-013" action="undecided"
      *           src="hunspell-en">
      *   <scx:w>trhe</scx:w>
      *   <scx:bogon>trhe</scx:bogon>
      *   <scx:alt>the</scx:alt>
      *   <scx:alt>tree</scx:alt>
      *   <scx:alt>true</scx:alt>
      *   <scx:alt>rhetor</scx:alt>
      *   <scx:raw>&amp; trhe 4 3635: the, tree, true, rhetor</scx:raw>
      * </scx:flag>
      *
      * @action : (undecided | add | addlc | accept | accept1x | sic | replace)
      *
      * scx:w is what displays in the running text.
      *   User's actions change it.
      * scx:bogon does not change; it records what was there
      *   when we started.
      * scx:alt and scx:raw are mostly for the record
      *-->  
</xsl:stylesheet>
