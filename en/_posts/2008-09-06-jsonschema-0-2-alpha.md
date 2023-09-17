---
layout: post
title: "jsonschema 0.2 alpha"
date: 2008-09-06 20:04:08 +0000
permalink: /en/jsonschema-0-2-alpha
blog: en
tags: python json jsonschema schema
render_with_liquid: false
---

<p>I just released a new version of jsonschema 0.2 alpha over at <a href="http://code.google.com/p/jsonschema">http://code.google.com/p/jsonschema</a></p>
<p>The source can be downloaded here: <a href="http://jsonschema.googlecode.com/files/jsonschema-0.2a.tar.gz">jsonschema-0.2a.tar.gz</a><br /> The documentation can be found here: <a href="http://www.bitbucket.org/IanLewis/jsonschema/raw/4ad1ade5779d/docs/jsonschema.html">jsonschema (version 0.2a) documentation</a></p>
<p>The new release includes the following notable changes.</p>
<ul>
<li>The additionalProperties attribute is now validated.</li>
<li>Using schemas in the type attribute now works properly.</li>
<li>Changed support for unique attribute to the "identity" attribute (Note: this is not a backwards compatible change)</li>
<li>Fixed a bug where the original schema object/dictionary was modified by the validator</li>
<li>Added a new "interactive mode" which will add default values to objects if not specified as readonly by the schema</li>
<li>Made error messages a bit more friendly.</li>
<li>Fixed bugs with validating Unicode strings</li>
</ul>
<p>The <a href="http://groups.google.com/group/json-schema/web/json-schema-proposal---second-draft">additionalProperties</a> attribute is used to define the format of additional properties that aren't explicitly specified in the properties attribute. This is useful for json like</p>
<div class="codeblock amc_javascript amc_short"><table><tr class="amc_code_odd"><td class="amc_line"><div class="amc1"></div></td><td><span style="color: #66cc66;">&#123;</span><br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc2"></div></td><td>&nbsp; bob: <span style="color: #CC0000;">10</span>,<br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc3"></div></td><td>&nbsp; sue: <span style="color: #CC0000;">20</span>,<br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc4"></div></td><td>&nbsp; bill: <span style="color: #CC0000;">30</span><br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc5"></div></td><td><span style="color: #66cc66;">&#125;</span></td></tr></table></div>
<p>where you have some things like game scores and the name of the attribute is someone's name which can't be defined in schema. You can use it like so:</p>
<div class="codeblock amc_javascript amc_short"><table><tr class="amc_code_odd"><td class="amc_line"><div class="amc1"></div></td><td><span style="color: #66cc66;">&#123;</span><br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc2"></div></td><td>&nbsp; <span style="color: #3366CC;">&quot;type&quot;</span>: <span style="color: #3366CC;">&quot;object&quot;</span>,<br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc3"></div></td><td>&nbsp; <span style="color: #3366CC;">&quot;additionalProperties&quot;</span>: <span style="color: #3366CC;">&quot;integer&quot;</span><br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc4"></div></td><td><span style="color: #66cc66;">&#125;</span></td></tr></table></div>
<p>The type field was also fixed so that it handles adding schemas as types, so now you can define,</p>
<div class="codeblock amc_javascript amc_short"><table><tr class="amc_code_odd"><td class="amc_line"><div class="amc1"></div></td><td><span style="color: #66cc66;">&#123;</span><br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc2"></div></td><td>&nbsp; <span style="color: #3366CC;">&quot;type&quot;</span>: <span style="color: #66cc66;">&#91;</span><br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc3"></div></td><td>&nbsp; &nbsp; <span style="color: #66cc66;">&#123;</span> <span style="color: #3366CC;">&quot;type&quot;</span>: <span style="color: #3366CC;">&quot;array&quot;</span>,  <span style="color: #3366CC;">&quot;minItems&quot;</span>: <span style="color: #CC0000;">10</span> <span style="color: #66cc66;">&#125;</span>,<br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc4"></div></td><td>&nbsp; &nbsp; <span style="color: #66cc66;">&#123;</span> <span style="color: #3366CC;">&quot;type&quot;</span>: <span style="color: #3366CC;">&quot;string&quot;</span>, <span style="color: #3366CC;">&quot;pattern&quot;</span>: <span style="color: #3366CC;">&quot;^0+$&quot;</span> <span style="color: #66cc66;">&#125;</span><br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc5"></div></td><td>&nbsp; <span style="color: #66cc66;">&#93;</span><br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc6"></div></td><td><span style="color: #66cc66;">&#125;</span></td></tr></table></div>
<p>This can let you define more complex types for use in schema.</p>
<div class="sharethis">
        <script type="text/javascript" language="javascript">
          SHARETHIS.addEntry( {
            title : 'jsonschema 0.2 alpha',
              url   : 'http://www.ianlewis.org/en/jsonschema-0-2-alpha'}, 
            { button: true }
          ) ;
        </script></div>
