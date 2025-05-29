<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<jsp:include page="header.jsp" />

<h2>Quản lý khách hàng</h2>

<form method="get" action="ManagerUserServlet">
    <input type="text" name="search" placeholder="Tìm theo tên/email..." value="${param.search}" />
    <select name="role">
        <option value="">Tất cả vai trò</option>
        <option value="GUEST" ${param.role == 'GUEST' ? 'selected' : ''}>Guest</option>
        <option value="RECEPTIONIST" ${param.role == 'RECEPTIONIST' ? 'selected' : ''}>Receptionist</option>
    </select>
    <button type="submit">Lọc</button>
</form>

<table border="1">
    <thead>
        <tr>
            <th><a href="?sort=id">ID</a></th>
            <th><a href="?sort=fullName">Tên</a></th>
            <th><a href="?sort=email">Email</a></th>
            <th>Vai trò</th>
            <th>Hành động</th>
        </tr>
    </thead>
    <tbody>
        <c:forEach var="u" items="${userList}">
            <tr>
                <td>${u.id}</td>
                <td>${u.fullName}</td>
                <td>${u.email}</td>
                <td>${u.role}</td>
                <td>
                    <form action="ManagerUserServlet" method="post" style="display:inline">
                        <input type="hidden" name="id" value="${u.id}" />
                        <button name="action" value="delete" onclick="return confirm('Xác nhận xóa?')">Xóa</button>
                        <button name="action" value="reject" onclick="return confirm('Từ chối user này?')">Từ chối</button>
                    </form>
                </td>
            </tr>
        </c:forEach>
    </tbody>
</table>

<div>
    <c:forEach begin="1" end="${totalPages}" var="i">
        <a href="?page=${i}">${i}</a>
    </c:forEach>
</div>

<jsp:include page="footer.jsp" />
