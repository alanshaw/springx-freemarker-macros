<#--
 * Copyright 2011 Alan Shaw
 * 
 * http://www.freestyle-developments.co.uk
 * http://github.com/alanshaw/springx-freemarker-macros
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and limitations
 * under the License.
-->

<#--
	FreeMarker spring macro extensions
	====================================================================================================================
	This file contains extensions to the default spring macros (spring.ftl) and other useful utilities.
-->

<#--
 * Alternative to spring's showErrors macro that allows you to specify the tag that the element should be wrapped in
 * (if any).
 *
 * @param separator the html tag or other character list that should be used to
 *    separate each option. Typically '<br>'.
 * @param classOrStyle either the name of a CSS class element (which is defined in
 *    the template or an external CSS file) or an inline style. If the value passed in here
 *    contains a colon (:) then a 'style=' attribute will be used, else a 'class=' attribute
 *    will be used.
 * @param tag The HTML tag to wrap the error in
-->
<#macro showErrors separator classOrStyle="" tag="">
	<#if (spring.status.errorMessages?size > 0)>
		<#list spring.status.errorMessages as error>
			<#if classOrStyle == "" && tag == "">
				${error}
			<#else>
				<#if classOrStyle == "">
					<${tag}>${error}</${tag}>
				<#else>
					<#if tag == ""><#local tag = "span" /></#if>
					<#if classOrStyle?index_of(":") == -1><#local attr="class"><#else><#local attr="style"></#if>
					<${tag} ${attr}="${classOrStyle}">${error}</${tag}>
				</#if>
			</#if>
			<#if error_has_next>${separator}</#if>
		</#list>
	</#if>
</#macro>

<#--
 * Shows errors from multiple bind paths.
 * 
 * @param bindPaths An array of bind baths to get errors from
 * @param separator the html tag or other character list that should be used to
 *    separate each option. Typically '<br>'.
 * @param classOrStyle either the name of a CSS class element (which is defined in
 *    the template or an external CSS file) or an inline style. If the value passed in here
 *    contains a colon (:) then a 'style=' attribute will be used, else a 'class=' attribute
 *    will be used.
 * @param tag The HTML tag to wrap the error in
-->
<#macro showMultipleBindPathErrors bindPaths separator classOrStyle="" tag="">
	<#-- Bind the first path -->
	<@spring.bind bindPaths[0] />
	<#list bindPaths as bindPath>
		<#-- Show errors for this bind bath -->
		<@showErrors separator classOrStyle tag />
		<#if bindPath_has_next>
			<#-- Bind the next path -->
			<@spring.bind bindPaths[bindPath_index + 1] />
			<#-- Echo the seperator if this bind path has error messages -->
			<#if (spring.status.errorMessages?size > 0)>
				${separator}
			</#if>
		</#if>
	</#list>
</#macro>

<#--
 * Shows errors for the current bind path in an unordered or ordered list
 * 
 * @param classOrStyle either the name of a CSS class element (which is defined in
 *    the template or an external CSS file) or an inline style. If the value passed in here
 *    contains a colon (:) then a 'style=' attribute will be used, else a 'class=' attribute
 *    will be used.
 * @param ordered Whether or not the macro should output the list as an <ol> or <ul>
-->
<#macro showErrorsList classOrStyle="" ordered=false>
	<#local list><@showErrors "", "", "li" /></#local>
	<@showList list, classOrStyle, ordered/>
</#macro>

<#--
 * Shows errors for multiple bind paths in an unordered or ordered list
 *
 * @param bindPaths An array of bind baths to get errors from
 * @param classOrStyle either the name of a CSS class element (which is defined in
 *    the template or an external CSS file) or an inline style. If the value passed in here
 *    contains a colon (:) then a 'style=' attribute will be used, else a 'class=' attribute
 *    will be used.
 * @param ordered Whether or not the macro should output the list as an <ol> or <ul>
-->
<#macro showMultipleBindPathErrorsList bindPaths classOrStyle="" ordered=false>
	<#local list><@showMultipleBindPathErrors bindPaths "", "", "li" /></#local>
	<@showList list, classOrStyle, ordered/>
</#macro>

<#--
 * Generates a "random" integer between min and max (inclusive)
 * 
 * Note the values this function returns are based on the current second the function is called and thus are highly
 * deterministic and SHOULD NOT be used for anything other than inconsequential purposes, such as picking a random
 * image to display.
-->
<#function rand min max>
	<#local now = .now?long?c />
	<#local randomNum = _rand + ("0." + now?substring(now?length-1) + now?substring(now?length-2))?number />
	<#if (randomNum > 1)>
		<#assign _rand = randomNum % 1 />
	<#else>
		<#assign _rand = randomNum />
	</#if>
	<#return (min + ((max - min) * _rand))?round />
</#function>
<#assign _rand = 0.36 />

<#--
 * Shows flow messages (which reside in flowRequestContext.messageContext)
 *
 * @param source Name of the field that caused the error
 * @param severity String representation of org.springframework.binding.message.Severity
 * @param separator the html tag or other character list that should be used to
 *    separate each option. Typically '<br>'.
 * @param classOrStyle either the name of a CSS class element (which is defined in
 *    the template or an external CSS file) or an inline style. If the value passed in here
 *    contains a colon (:) then a 'style=' attribute will be used, else a 'class=' attribute
 *    will be used.
 * @param tag The HTML tag to wrap the error in
-->
<#macro showFlowMessages source severity separator classOrStyle="" tag="">
	<#local messages = flowRequestContext.messageContext.getMessagesBySource(source)/>
	<#if (messages?size > 0)>
		<#list messages as message>
			<#if message.severity?string == severity>
				<#if classOrStyle == "" && tag == "">
					${message.getText()}
				<#else>
					<#if classOrStyle == "">
						<${tag}>${message.getText()}</${tag}>
					<#else>
						<#if tag == ""><#local tag = "span" /></#if>
						<#if classOrStyle?index_of(":") == -1><#local attr="class"><#else><#local attr="style"></#if>
						<${tag} ${attr}="${classOrStyle}">${message.getText()}</${tag}>
					</#if>
				</#if>
				<#if message_has_next>${separator}</#if>
			</#if>
		</#list>
	</#if>
</#macro>

<#--
 * Shows errors from multiple sources.
 * 
 * @param sources An array of sources to get errors from
 * @param severity String representation of org.springframework.binding.message.Severity
 * @param separator the html tag or other character list that should be used to
 *    separate each option. Typically '<br>'.
 * @param classOrStyle either the name of a CSS class element (which is defined in
 *    the template or an external CSS file) or an inline style. If the value passed in here
 *    contains a colon (:) then a 'style=' attribute will be used, else a 'class=' attribute
 *    will be used.
 * @param tag The HTML tag to wrap the error in
-->
<#macro showMultipleSourceFlowMessages sources severity separator classOrStyle="" tag="">
	<#list sources as source>
		<#-- Show errors for this source -->
		<@showFlowMessages source, severity, separator classOrStyle tag />
		<#if source_has_next>
			<#-- Echo the seperator if this source has error messages -->
			<#local hasMessages = false/>
			<#local messages = flowRequestContext.messageContext.getMessagesBySource(source)/>
			<#list messages as message>
				<#if message.severity?string == severity>
					<#local hasMessages = true/>
					<#break/>
				</#if>
			</#list>
			<#if hasMessages>
				${separator}
			</#if>
		</#if>
	</#list>
</#macro>

<#--
 * Shows flow messages (which reside in flowRequestContext.messageContext) in an ordered or unordered list
 *
 * @param source Name of the field that caused the error
 * @param severity String representation of org.springframework.binding.message.Severity
 * @param classOrStyle either the name of a CSS class element (which is defined in
 *    the template or an external CSS file) or an inline style. If the value passed in here
 *    contains a colon (:) then a 'style=' attribute will be used, else a 'class=' attribute
 *    will be used.
 * @param ordered Whether or not the macro should output the list as an <ol> or <ul>
-->
<#macro showFlowMessagesList source severity classOrStyle="" ordered=false>
	<#local list><@showFlowMessages source, severity, "", "", "li" /></#local>
	<@showList list, classOrStyle, ordered/>
</#macro>

<#--
 * Shows errors for multiple sources in an unordered or ordered list
 *
 * @param sources An array of sources to get errors from
 * @param severity String representation of org.springframework.binding.message.Severity
 * @param classOrStyle either the name of a CSS class element (which is defined in
 *    the template or an external CSS file) or an inline style. If the value passed in here
 *    contains a colon (:) then a 'style=' attribute will be used, else a 'class=' attribute
 *    will be used.
 * @param ordered Whether or not the macro should output the list as an <ol> or <ul>
-->
<#macro showMultipleSourceFlowMessagesList sources, severity, classOrStyle="" ordered=false>
	<#local list><@showMultipleSourceFlowMessages sources, severity "", "", "li" /></#local>
	<@showList list, classOrStyle, ordered/>
</#macro>

<#--
 * Displays the passed content in an ordered/unordered list
 *
 * @param content A string of content to display
 * @param classOrStyle either the name of a CSS class element (which is defined in
 *    the template or an external CSS file) or an inline style. If the value passed in here
 *    contains a colon (:) then a 'style=' attribute will be used, else a 'class=' attribute
 *    will be used.
 * @param ordered Whether or not the macro should output the list as an <ol> or <ul>
-->
<#macro showList content classOrStyle="" ordered=false>
	<#if content?trim != "">
		<#if classOrStyle == "">
			<#local attr="">
		<#elseif classOrStyle?index_of(":") == -1>
			<#local attr=" class=" + classOrStyle>
		<#else>
			<#local attr=" style=" + classOrStyle>
		</#if>
		<#if ordered><ol${attr}><#else><ul${attr}></#if>
		${content}
		<#if ordered></ol><#else></ul></#if>
	</#if>
</#macro>

<#--
 * Determines whether there are any messages at the given severity for the given message sources.
 *
 * @param sources An array of sources to get errors from (or string if only one source)
 * @param severity String representation of org.springframework.binding.message.Severity. Additionally pass "ALL" or
 * omit the param to determine if there are any messages for all severities
 * @return Whether or not there are any messages
-->
<#function hasFlowMessages sources severity="ALL">
	<#if sources?is_string><#local sources = [sources]/></#if>
	<#list sources as source>
		<#local messages = flowRequestContext.messageContext.getMessagesBySource(source)/>
		<#if (messages?size > 0 && severity == "ALL")><#return true/></#if>
		<#list messages as message>
			<#if message.severity?string == severity>
				<#return true/>
			</#if>
		</#list>
	</#list>
	<#return false/>
</#function>