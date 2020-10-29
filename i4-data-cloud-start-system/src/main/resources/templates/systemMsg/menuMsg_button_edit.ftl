<@override name="body">
<title>爱思数据云平台·系统管理/按钮管理</title>
<body>
<div style="width: 90%;text-align: center;">
    <form class="layui-form">
        <br>
        <div class="layui-form-item">
            <label class="layui-form-label">所属菜单：</label>
            <div class="layui-input-block">
                <input readonly value="${pMenu.name!}" class="layui-input">
                <input type="hidden" value="${pMenu.id!}" name="parentId" class="layui-input">
            </div>
        </div>

        <input type="hidden" value="${menu.type!}" name="type" class="layui-input"><!--标注是按钮-->

        <div class="layui-form-item">
            <label class="layui-form-label">按钮名称：</label>
            <div class="layui-input-block">
                <input type="text" value="${menu.name!}" name="name" lay-verify="required" placeholder="请输入按钮名称" class="layui-input">
            </div>
        </div>
        <div class="layui-form-item">
            <label class="layui-form-label">按钮链接：</label>
            <div class="layui-input-block">
                <input type="text" value="${menu.url!}" name="url" placeholder="请输入按钮链接" class="layui-input">
            </div>
        </div>
        <div class="layui-form-item">
            <label class="layui-form-label">权限标识：</label>
            <div class="layui-input-block">
                <input type="text" value="${menu.permission!}" name="permission" placeholder="shiro控制权限" class="layui-input">
            </div>
        </div>
        <div class="layui-form-item">
            <label class="layui-form-label">按钮排序：</label>
            <div class="layui-input-block">
                <input type="number" value="${menu.sort!}" name="sort" lay-verify="required" placeholder="默认自增升序" class="layui-input">
            </div>
        </div>
        <input type="hidden" name="id" value="${menu.id}">
        <div class="layui-form-item">
            <div class="layui-input-block">
                <button class="layui-btn" lay-submit lay-filter="save">立即提交</button>
                <button type="button" class="layui-btn layui-btn-danger" onclick="parent.layer.closeAll()">关闭</button>
            </div>
        </div>
    </form>
</div>
</body>
<script type="text/javascript" src="${StaticServer}/templates/systemMsg/menuMsg_button_edit.js?v=1.0"></script>
</@override>
<@extends name="/base.ftl"/>