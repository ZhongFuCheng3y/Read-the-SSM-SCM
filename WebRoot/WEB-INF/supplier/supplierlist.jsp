<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@include file="/common/common.jspf"%>
<html>
<head>


<title></title>
<style type="text/css">
.searchbox{
	margin:-3
}
</style>

<script type="text/javascript">
	$(function(){
	
			$('#dg').datagrid({    
			    url:'${proPath}/datagrid_data1.json', 
			    fitColumns:true,
			    nowrapL:true,
			    //idField:
			    rownumbers:true,
			    pagination:true,
			    pageSize:5,
			    pageList:[3,5,10,20],
			    
			  /*   queryParams: {
					name: 'easyui',
					subject: 'datagrid'
				}, */
						    
			    toolbar: [{
					iconCls: 'icon-add',
					text:'新增',
					handler: function(){
						alert('新增按钮');
					}
				},'-',{
					iconCls: 'icon-edit',
					text:'修改',
					handler: function(){
						alert('修改按钮');
					}
				},'-',{
					iconCls: 'icon-remove',
					text:'删除',
					handler: function(){
						alert('删除按钮');
					}
				},'-',{
					text:"<input type='text' id='ss' name='keyWord'/>",					
				}],
			       
			    
				columns : [ [{
					checkbox:true,
				}, {
				field : 'productid',
				title : '产品编号',
				width : 100
			}, {
				field : 'productname',
				title : '产品名称',
				width : 100
			}, {
				field : 'listprice',
				title : '价格',
				width : 100,
				align : 'right'
			} ] ]
		});
		
		$('#ss').searchbox({ 
			searcher:function(value,name){ 
				alert(value + "," + name); 
			}, 			
			prompt:'请输入供应商名称' 
		}); 

	});
</script>
</head>

<body>
	<table id="dg"></table>
</body>
</html>