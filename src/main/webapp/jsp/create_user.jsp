<%-- 
    Document   : create_user
    Created on : May 30, 2025, 8:42:42 AM
    Author     : he187
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
        <form method="post" action="/ManagerUserServlet">
            <label>Username:</label><input type="text" name="username" required><br>
            <label>Password:</label><input type="password" name="password" required><br>
            <label>Full Name:</label><input type="text" name="fullName"><br>
            <label>Email:</label><input type="email" name="email"><br>
            <label>Phone:</label><input type="text" name="phone"><br>
            <label>Role:</label><input type="text" name="role"><br>
            <input type="submit" value="Create User">
        </form>
        
        <% if (request.getAttribute("error") != null) { %>
        <p style="color:red;"><%= request.getAttribute("error") %></p>
        <% } %>
    </body>
</html>
