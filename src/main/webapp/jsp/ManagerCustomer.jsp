<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manager Customer</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        .container {
            width: 90%;
            margin: auto;
        }
        .create-button {
            margin: 20px 0;
            padding: 10px 20px;
            font-size: 16px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 5px;
        }
        .user-card {
            display: flex;
            align-items: center;
            border: 1px solid #ccc;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 15px;
        }
        .avatar {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background-color: #eee;
            margin-right: 20px;
            flex-shrink: 0;
        }
        .user-info {
            flex-grow: 1;
        }
        .user-actions {
            display: flex;
            gap: 10px;
        }
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 20px;
            cursor: pointer;
            font-weight: bold;
        }
        .btn-update {
            background-color: #2196F3;
            color: white;
        }
        .btn-delete {
            background-color: #f44336;
            color: white;
        }
    </style>
</head>
<body>
    <div class="container">
        <a href="jsp/create_user.jsp">
            <button class="create-button">Create User</button>
        </a>

        <%
            List<User> users = (List<User>) request.getAttribute("users");
            if (users != null && !users.isEmpty()) {
                for (User user : users) {
        %>
        <div class="user-card">
            <div class="avatar"></div>
            <div class="user-info">
                <h3><%= user.getFullName() %></h3>
                <p>Username: <%= user.getUsername() %></p>
                <p>Email: <%= user.getEmail() %></p>
                <p>Phone: <%= user.getPhone() %></p>
                <p>Role: <%= user.getRole() %></p>
            </div>
            <div class="user-actions">
                <form method="get" action="update_user.jsp">
                    <input type="hidden" name="id" value="<%= user.getId() %>">
                    <button type="submit" class="btn btn-update">Update</button>
                </form>
                <form method="post" action="deleteUser">
                    <input type="hidden" name="id" value="<%= user.getId() %>">
                    <button type="submit" class="btn btn-delete">Delete</button>
                </form>
            </div>
        </div>
        <%
                }
            } else {
        %>
            <p>No users found.</p>
        <%
            }
        %>
    </div>


        
        <jsp:include page="footer.jsp" />
        
        <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap/js/popper.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap/js/bootstrap.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap-select/bootstrap-select.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap-touchspin/jquery.bootstrap-touchspin.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/magnific-popup/magnific-popup.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/counter/waypoints-min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/counter/counterup.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/imagesloaded/imagesloaded.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/masonry/masonry.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/masonry/filter.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/owl-carousel/owl.carousel.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/functions.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/contact.js"></script>
        <script src='${pageContext.request.contextPath}/assets/vendors/switcher/switcher.js'></script>
    </body>
</html>


