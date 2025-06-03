<%@ page language="java" contentType="text/html; charset=UTF-8" import="java.util.List, dal.BlogDAO, model.Blog" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Room" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <!-- META -->
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="keywords" content="" />
        <meta name="author" content="" />
        <meta name="robots" content="" />
        <meta name="description" content="EduChamp : Education HTML Template" />
        <meta property="og:title" content="EduChamp : Education HTML Template" />
        <meta property="og:description" content="EduChamp : Education HTML Template" />
        <meta property="og:image" content="" />
        <meta name="format-detection" content="telephone=no">
        <link rel="icon" href="${pageContext.request.contextPath}/assets/images/favicon.ico" type="image/x-icon" />
        <link rel="shortcut icon" type="image/x-icon" href="${pageContext.request.contextPath}/assets/images/favicon.png" />
        <title>House Keeping</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <!-- CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/assets.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/typography.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shortcodes/shortcodes.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
        <link class="skin" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/color/color-1.css">
    </head>
    <body id="bg">
        <div class="page-wraper">
            <div id="loading-icon-bx"></div>
            <!-- Header -->
            <header class="header rs-nav">
                <!-- Top bar and nav (copy from static template) -->
                <%@ include file="header.jsp" %>
            </header>

            <!-- Inner Content Box -->
            <div class="page-content bg-white">
                <!-- Page Heading -->
                <div class="page-banner ovbl-dark" style="background-image:url(${pageContext.request.contextPath}/assets/images/banner/banner2.jpg);">
                    <div class="container">
                        <div class="page-banner-entry">
                            <h1 class="text-white">HouseKeeping</h1>
                        </div>
                    </div>
                </div>
                <div class="breadcrumb-row">
                    <div class="container">
                        <ul class="list-inline">
                            <li><a href="index.jsp">Home</a></li>
                            <li>HouseKeeping</li>
                        </ul>
                    </div>
                </div>
<!-- code -->
    <%List<Room> rooms = (List<Room>) request.getAttribute("rooms");
    String search = request.getAttribute("search") != null ? (String) request.getAttribute("search") : "";
    String status = request.getAttribute("status") != null ? (String) request.getAttribute("status") : "ALL";
%>
<html>
<head>
    <title>Housekeeping - Quản lý phòng</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { padding: 10px; border: 1px solid #ccc; text-align: center; }
        select, input[type=text] { padding: 5px; }
        form.inline { display: inline; }
    </style>
</head>
<body>
    <h2>Housekeeping - Quản lý trạng thái phòng</h2>

    <!-- Form lọc và tìm kiếm phòng (gửi GET -> gọi doGet()) -->
    <form method="get" action="housekeeping">
        <label>Tìm theo số phòng:</label>
        <input type="text" name="search" value="<%= search %>" placeholder="Nhập số phòng..." />

        <label>Lọc theo trạng thái:</label>
        <select name="status">
            <option value="ALL" <%= "ALL".equals(status) ? "selected" : "" %>>Tất cả</option>
            <option value="AVAILABLE" <%= "AVAILABLE".equals(status) ? "selected" : "" %>>AVAILABLE</option>
            <option value="OCCUPIED" <%= "OCCUPIED".equals(status) ? "selected" : "" %>>OCCUPIED</option>
            <option value="MAINTENANCE" <%= "MAINTENANCE".equals(status) ? "selected" : "" %>>MAINTENANCE</option>
            <option value="DIRTY" <%= "DIRTY".equals(status) ? "selected" : "" %>>DIRTY</option>
        </select>

        <input type="submit" value="Lọc / Tìm" />
    </form>

    <!-- Bảng hiển thị danh sách phòng -->
    <table>
        <thead>
        <tr>
            <th>ID</th>
            <th>Số phòng</th>
            <th>Trạng thái hiện tại</th>
            <th>Thay đổi trạng thái</th>
        </tr>
        </thead>
        <tbody>
        <%
            if (rooms != null && !rooms.isEmpty()) {
                for (Room r : rooms) {
        %>
        <tr>
            <td><%= r.getId() %></td>
            <td><%= r.getRoomNumber() %></td>
            <td><%= r.getStatus() %></td>
            <td>
                <!-- Form cập nhật trạng thái phòng (POST -> gọi doPost()) -->
                <form method="post" action="housekeeping" class="inline">
                    <input type="hidden" name="roomId" value="<%= r.getId() %>" />
                    <select name="newStatus">
                        <option value="AVAILABLE" <%= "AVAILABLE".equals(r.getStatus()) ? "selected" : "" %>>AVAILABLE</option>
                        <option value="OCCUPIED" <%= "OCCUPIED".equals(r.getStatus()) ? "selected" : "" %>>OCCUPIED</option>
                        <option value="MAINTENANCE" <%= "MAINTENANCE".equals(r.getStatus()) ? "selected" : "" %>>MAINTENANCE</option>
                        <option value="DIRTY" <%= "DIRTY".equals(r.getStatus()) ? "selected" : "" %>>DIRTY</option>
                    </select>
                    <input type="submit" value="Cập nhật" />
                </form>
            </td>
        </tr>
        <%
                }
            } else {
        %>
        <tr><td colspan="4">Không tìm thấy phòng nào.</td></tr>
        <%
            }
        %>
        </tbody>
    </table>
</body>
</html>

        </div>
                                   <%@ include file="footer.jsp" %>
 </div>

        <!-- Footer -->




        <!-- JS -->
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
       

    </body>
</html>