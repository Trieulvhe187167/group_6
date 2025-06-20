<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Error</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f8f9fa; color: #333; }
        .error-container { max-width: 600px; margin: 60px auto; background: #fff; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); padding: 32px; }
        h2 { color: #c0392b; }
        .error-message { margin: 20px 0; font-size: 1.2em; color: #b71c1c; }
        .back-link { display: inline-block; margin-top: 24px; color: #2980b9; text-decoration: none; }
        .back-link:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="error-container">
        <h2>Đã xảy ra lỗi!</h2>
        <div class="error-message">
            <%-- Hiển thị lỗi từ attribute 'error' --%>
            <c:if test="${not empty error}">
                ${error}
            </c:if>
            <%-- Nếu không có attribute 'error', hiển thị lỗi mặc định --%>
            <c:if test="${empty error}">
                Đã xảy ra lỗi không xác định. Vui lòng thử lại sau.
            </c:if>
        </div>
        <a class="back-link" href="<%= request.getContextPath() %>/index.jsp">&larr; Về trang chủ</a>
    </div>
</body>
</html>