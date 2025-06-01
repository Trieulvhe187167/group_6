<%@page contentType="text/html" pageEncoding="UTF-8"%>
<html>
<head><title>Quên Mật Khẩu</title></head>
<body>
<h2>Quên Mật Khẩu</h2>
<form method="post" action="../ForgotPasswordServlet">
    Email: <input type="email" name="email" required />
    <input type="submit" value="Gửi liên kết đặt lại mật khẩu" />
</form>
<p style="color:green">${message}</p>
<p style="color:red">${error}</p>
</body>
</html>
