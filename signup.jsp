<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Sign Up</title>
</head>
<body>
    <h2>Sign Up Page</h2>
    <form action="signup" method="post">
        Last Name (Họ): <input type="text" name="lastName" required><br><br>
        First Name (Tên): <input type="text" name="firstName" required><br><br>
        Username: <input type="text" name="username" required><br><br>
        Password: <input type="password" name="password" required><br><br>
        Email: <input type="email" name="email" required><br><br>
        Phone Number: <input type="tel" name="phone" pattern="[0-9]{10,15}" required><br><br>
        <input type="submit" value="Sign Up">
    </form>
</body>
</html>
