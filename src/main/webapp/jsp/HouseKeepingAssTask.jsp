<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Assign Housekeeping Task - Luxury Hotel</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    
    <!-- CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/assets.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/typography.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shortcodes/shortcodes.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/color/color-1.css">

    <style>
        .text-danger {
            color: #dc3545;
        }
    </style>
</head>
<body id="bg">
<div class="page-wraper">
    <!-- Header -->
    <jsp:include page="/jsp/header.jsp" />

    <!-- Content -->
    <div class="page-content bg-white">
        <div class="page-banner ovbl-dark" style="background-image:url(${pageContext.request.contextPath}/assets/images/banner/banner2.jpg);">
            <div class="container">
                <div class="page-banner-entry">
                    <h1 class="text-white">Assign Housekeeping Task</h1>
                </div>
            </div>
        </div>

        <div class="breadcrumb-row">
            <div class="container">
                <ul class="list-inline">
                    <li><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/houseKeepingManager">Housekeeping</a></li>
                    <li>Assign Task</li>
                </ul>
            </div>
        </div>

        <!-- Main Content -->
        <div class="section-area section-sp1">
            <div class="container">
                <div class="row">
                    <div class="col-lg-8 col-md-10 col-sm-12 m-auto">
                        <div style="background-color: #f8f9fa; padding: 40px; border-radius: 10px;">
                            <form method="post" action="${pageContext.request.contextPath}/admin/houseKeepingManager" style="display:inline;" class="contact-bx">
                                <input type="hidden" name="action" value="addTask"/>

                                <div class="heading-bx left mb-4">
                                    <h2 class="title-head">Assign <span>Task</span></h2>
                                </div>

                                <!-- Room ID -->
                                <div class="form-group">
                                    <label>Room <span class="text-danger">*</span></label>
                                    <select name="roomId" class="form-control" required>
                                        <option value="">-- Select Room --</option>
                                        <c:forEach var="room" items="${roomList}">
                                            <option value="${room.id}">${room.name}</option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <!-- Assigned To -->
                                <div class="form-group">
                                    <label>Assigned To <span class="text-danger">*</span></label>
                                    <select name="assignedTo" class="form-control" required>
                                        <option value="">-- Select Staff --</option>
                                        <c:forEach var="staff" items="${staffList}">
                                            <option value="${staff.id}">${staff.fullName}</option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <!-- Status -->
                                <div class="form-group">
                                    <label>Status <span class="text-danger">*</span></label>
                                    <select name="status" class="form-control" required>
                                        <option value="">-- Select Status --</option>
                                        <c:forEach var="s" items="${statusList}">
                                            <option value="${s}">${s}</option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <!-- Notes -->
                                <div class="form-group">
                                    <label>Notes</label>
                                    <textarea name="notes" class="form-control" placeholder="Enter any notes..." rows="4"></textarea>
                                </div>

                                <!-- Submit -->
                                <div class="form-group">
                                    <button type="submit" class="btn button-md">Assign Task</button>
                                    <a href="${pageContext.request.contextPath}/admin/houseKeepingManager" class="btn btn-secondary button-md">Cancel</a>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <jsp:include page="/jsp/footer.jsp" />
</div>

<!-- JS -->
<script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendors/bootstrap/js/popper.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/vendors/bootstrap/js/bootstrap.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/functions.js"></script>
</body>
</html>
