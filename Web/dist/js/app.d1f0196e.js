(function(e){function t(t){for(var r,o,c=t[0],s=t[1],l=t[2],m=0,f=[];m<c.length;m++)o=c[m],Object.prototype.hasOwnProperty.call(a,o)&&a[o]&&f.push(a[o][0]),a[o]=0;for(r in s)Object.prototype.hasOwnProperty.call(s,r)&&(e[r]=s[r]);u&&u(t);while(f.length)f.shift()();return i.push.apply(i,l||[]),n()}function n(){for(var e,t=0;t<i.length;t++){for(var n=i[t],r=!0,c=1;c<n.length;c++){var s=n[c];0!==a[s]&&(r=!1)}r&&(i.splice(t--,1),e=o(o.s=n[0]))}return e}var r={},a={app:0},i=[];function o(t){if(r[t])return r[t].exports;var n=r[t]={i:t,l:!1,exports:{}};return e[t].call(n.exports,n,n.exports,o),n.l=!0,n.exports}o.m=e,o.c=r,o.d=function(e,t,n){o.o(e,t)||Object.defineProperty(e,t,{enumerable:!0,get:n})},o.r=function(e){"undefined"!==typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(e,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(e,"__esModule",{value:!0})},o.t=function(e,t){if(1&t&&(e=o(e)),8&t)return e;if(4&t&&"object"===typeof e&&e&&e.__esModule)return e;var n=Object.create(null);if(o.r(n),Object.defineProperty(n,"default",{enumerable:!0,value:e}),2&t&&"string"!=typeof e)for(var r in e)o.d(n,r,function(t){return e[t]}.bind(null,r));return n},o.n=function(e){var t=e&&e.__esModule?function(){return e["default"]}:function(){return e};return o.d(t,"a",t),t},o.o=function(e,t){return Object.prototype.hasOwnProperty.call(e,t)},o.p="/";var c=window["webpackJsonp"]=window["webpackJsonp"]||[],s=c.push.bind(c);c.push=t,c=c.slice();for(var l=0;l<c.length;l++)t(c[l]);var u=s;i.push([0,"chunk-vendors"]),n()})({0:function(e,t,n){e.exports=n("56d7")},"56d7":function(e,t,n){"use strict";n.r(t);n("e260"),n("e6cf"),n("cca6"),n("a79d");var r=n("7a23"),a={id:"main-container"},i={key:0},o=Object(r["e"])("h3",null,"Register",-1),c={key:1},s=Object(r["e"])("a",{href:"/"},[Object(r["e"])("img",{class:"logo",src:"/img/SwiftUI-Jam-Logo-Small@2x.png",width:"128",height:"128"}),Object(r["e"])("h1",null,"SwiftUI Jam")],-1),l={key:2},u={key:3},m=Object(r["e"])("h3",null,"Registration complete. You will be contacted with more information.",-1),f=Object(r["e"])("a",{href:"/"},"Home",-1);function b(e,t,n,b,d,p){var O=Object(r["j"])("Register");return Object(r["f"])(),Object(r["c"])("div",a,["home"==e.currentView?(Object(r["f"])(),Object(r["c"])("div",i,[Object(r["e"])("a",{class:"nav-item",onClick:t[1]||(t[1]=function(e){return p.goToRegister()})},[o])])):Object(r["d"])("",!0),"home"!=e.currentView?(Object(r["f"])(),Object(r["c"])("header",c,[s])):Object(r["d"])("",!0),"register"==e.currentView?(Object(r["f"])(),Object(r["c"])("div",l,[Object(r["e"])(O,{onRegistrationComplete:p.goToRegisterConfirmation},null,8,["onRegistrationComplete"])])):Object(r["d"])("",!0),"confirmation"==e.currentView?(Object(r["f"])(),Object(r["c"])("div",u,[m,f])):Object(r["d"])("",!0)])}n("b0c0");var d=Object(r["p"])("data-v-485c04fa");Object(r["h"])("data-v-485c04fa");var p={class:"register"},O=Object(r["e"])("h1",null,"Register",-1),j=Object(r["e"])("label",{for:"registerAs"},"Register As:",-1),g=Object(r["e"])("option",{value:"team-captain"},"Team Captain/Solo Programmer",-1),h=Object(r["e"])("option",{value:"team-member"},"Team Member",-1),v=Object(r["e"])("option",{value:"floater"},"Floating Designer",-1),y=Object(r["e"])("label",{for:"name"},"Name",-1),w=Object(r["e"])("label",{for:"email"},"Email",-1),T={key:0},D=Object(r["e"])("label",{for:"newTeamName"},"New Team Name",-1),x=Object(r["e"])("label",{for:"requiresFloater"},"Requesting Floating Designer?",-1),k={key:1},R=Object(r["e"])("label",{for:"existingTeamId"},"Select the team you are joining",-1),V=Object(r["e"])("br",null,null,-1),P=Object(r["e"])("br",null,null,-1),S={key:3},N=Object(r["e"])("strong",{class:"warning"},"Complete the form to continue",-1),A={key:4},I=Object(r["e"])("strong",null,"Processing...",-1);Object(r["g"])();var q=d((function(e,t,n,a,i,o){return Object(r["f"])(),Object(r["c"])("div",p,[O,Object(r["e"])("form",null,[j,Object(r["o"])(Object(r["e"])("select",{name:"registerAs",id:"registerAs","onUpdate:modelValue":t[1]||(t[1]=function(t){return e.registerAs=t})},[g,h,v],512),[[r["m"],e.registerAs]]),y,Object(r["o"])(Object(r["e"])("input",{type:"text",name:"name",id:"name","onUpdate:modelValue":t[2]||(t[2]=function(t){return e.formData.name=t})},null,512),[[r["n"],e.formData.name]]),w,Object(r["o"])(Object(r["e"])("input",{type:"email",name:"email",id:"email","onUpdate:modelValue":t[3]||(t[3]=function(t){return e.formData.email=t})},null,512),[[r["n"],e.formData.email]]),"team-captain"==e.registerAs?(Object(r["f"])(),Object(r["c"])("div",T,[D,Object(r["o"])(Object(r["e"])("input",{type:"text",name:"newTeamName",id:"newTeamName","onUpdate:modelValue":t[4]||(t[4]=function(t){return e.formData.newTeamName=t})},null,512),[[r["n"],e.formData.newTeamName]]),x,Object(r["o"])(Object(r["e"])("input",{type:"checkbox",name:"requiresFloater",id:"requiresFloater","onUpdate:modelValue":t[5]||(t[5]=function(t){return e.formData.requiresFloater=t})},null,512),[[r["l"],e.formData.requiresFloater]])])):Object(r["d"])("",!0),"team-member"==e.registerAs?(Object(r["f"])(),Object(r["c"])("div",k,[R,Object(r["o"])(Object(r["e"])("select",{name:"existingTeamId",id:"existingTeamId","onUpdate:modelValue":t[6]||(t[6]=function(t){return e.formData.existingTeamId=t})},[(Object(r["f"])(!0),Object(r["c"])(r["a"],null,Object(r["i"])(e.teams,(function(e){return Object(r["f"])(),Object(r["c"])("option",{key:e.id,value:e.id},Object(r["k"])(e.name),9,["value"])})),128))],512),[[r["m"],e.formData.existingTeamId]])])):Object(r["d"])("",!0),V,P,!e.isProcessing&&o.isValid?(Object(r["f"])(),Object(r["c"])("button",{key:2,type:"submit",onClick:t[7]||(t[7]=function(e){return o.register()})},"Submit")):Object(r["d"])("",!0),o.isValid?Object(r["d"])("",!0):(Object(r["f"])(),Object(r["c"])("div",S,[N])),e.isProcessing?(Object(r["f"])(),Object(r["c"])("div",A,[I])):Object(r["d"])("",!0)])])})),C={name:"Register",data:function(){return{registerAs:"team-captain",isProcessing:!1,teams:[],formData:{name:null,email:null,newTeamName:null,existingTeamId:null,requiresFloater:!1}}},created:function(){this.loadTeams()},computed:{isValid:function(){return null!=this.formData.name&&0!=this.formData.name.length&&null!=this.formData.email&&0!=this.formData.email.length&&(("team-captain"!=this.registerAs||null!=this.formData.newTeamName&&0!=this.formData.newTeamName.length)&&("team-member"!=this.registerAs||null!=this.formData.existingTeamId))}},methods:{loadTeams:function(){var e=this,t=new XMLHttpRequest;t.onload=function(){t.status>=200&&t.status<300?(console.log(t.response),e.teams=JSON.parse(t.responseText)):alert(t.responseText)},t.open("GET","/api/teams"),t.send()},register:function(){var e=this;console.log("register",JSON.stringify(this.formData));var t=this;t.isProcessing=!0;var n="register-";switch(this.registerAs){case"team-captain":n+="captain";break;case"team-member":n+="team-member";break;case"floater":n+="floater";break;default:return void console.log("unexpected path")}var r=new XMLHttpRequest;r.onload=function(){r.status>=200&&r.status<300?(console.log(r.response),e.$emit("registrationComplete")):alert(r.responseText),t.isProcessing=!1},r.open("POST","/api/".concat(n)),r.setRequestHeader("Content-Type","application/json"),r.send(JSON.stringify(this.formData))}}};n("6662");C.render=q,C.__scopeId="data-v-485c04fa";var F=C,U={name:"App",components:{Register:F},data:function(){return{currentView:"home"}},methods:{goToRegister:function(){this.currentView="register",document.getElementById("intro").remove()},goToRegisterConfirmation:function(){this.currentView="confirmation"}}};n("c88d");U.render=b;var _=U;Object(r["b"])(_).mount("#app")},"59e5":function(e,t,n){},6662:function(e,t,n){"use strict";n("59e5")},"6c78":function(e,t,n){},c88d:function(e,t,n){"use strict";n("6c78")}});
//# sourceMappingURL=app.d1f0196e.js.map