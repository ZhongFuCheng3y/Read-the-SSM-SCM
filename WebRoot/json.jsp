<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>

<c:set var="proPath" value="${pageContext.request.contextPath}" />
<link rel="stylesheet" type="text/css"
	href="${proPath}/jquery-easyui-1.3.5/themes/default/easyui.css">
<link rel="stylesheet" type="text/css" href="${proPath}/jquery-easyui-1.3.5/themes/icon.css">
<script type="text/javascript" src="${proPath}/jquery-easyui-1.3.5/jquery.min.js"></script>
<script type="text/javascript" src="${proPath}/jquery-easyui-1.3.5/jquery.easyui.min.js"></script>

  
    <title>My JSP 'json.jsp' starting page</title>
  	<script type="text/javascript">
  		$(function(){
	  			$("#bt1").click(
	  				function(){
		  				$.post(
		  					"supplier/doAjax.action",
		  					{supId:1001,supName:"name1001"},
		  					function(json){
		  						alert(json.supId+"||"+json.supName);
		  					},
		  					"json"
		  				);
		  			}
	  			);	  			
	  		}
  		);
  	
  	</script>
  
  </head>  
  <body>
 	<button id="bt1" >testJson</button> 
  </body>
</html>