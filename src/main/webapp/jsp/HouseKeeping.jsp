<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
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

    <style>
        body { font-family: Arial; padding: 20px; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { padding: 10px; border: 1px solid #ccc; text-align: center; }
        select, input[type=text] { padding: 5px; }
        form.inline { display: inline; }
    </style>
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

       </div>
<!-- code -->
            <!-- Main Content -->
<div class="section-area section-sp1">
    <div class="container">

        <!-- Success/Error Messages -->
        <c:if test="${param.success eq 'added'}">
            <div class="alert alert-success">Task added successfully!</div>
        </c:if>
        <c:if test="${param.success eq 'updated'}">
            <div class="alert alert-success">Task updated successfully!</div>
        </c:if>
        <c:if test="${param.success eq 'deleted'}">
            <div class="alert alert-success">Task deleted successfully!</div>
        </c:if>
        <c:if test="${param.error eq 'delete'}">
            <div class="alert alert-danger">Failed to delete task!</div>
        </c:if>

        <!-- Search and Add Button -->
        <div class="row mb-4">
            <div class="col-md-6">
                <form action="${pageContext.request.contextPath}/admin/housekeeping" method="get" class="form-inline">
                    <input type="hidden" name="action" value="search">
                    <div class="input-group">
                        <input type="text" name="status" class="form-control"
                               placeholder="Search by status (exact match)..."
                               value="${searchStatus}" style="width: 300px;">
                        <div class="input-group-append" style="margin-left: 10px;">
                            <button type="submit" class="btn btn-primary">
                                <i class="fa fa-search"></i> Search
                            </button>
                        </div>
                    </div>
                </form>
            </div>
            <div class="col-md-6 text-end">
                <a href="${pageContext.request.contextPath}/jsp/HouseKeepingAssTask.jsp"
                   class="btn btn-success">
                    <i class="fa fa-plus"></i> Add Task
                </a>
            </div>
        </div>

        <!-- Task Table -->
        <div class="table-responsive">
            <table class="table table-striped table-bordered">
                <thead class="table-light">
                    <tr>
                        <th>ID</th>
                        <th>Room Number</th>
                        <th>Status</th>
                        <th>Assigned To</th>
                        <th>Task</th>
                        <th>Updated At</th>
                        
                        <th style="width: 150px;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="task" items="${tasks}">
                        <tr>
                            <td>${task.id}</td>
                            <td>${task.roomNum}</td>
                            <td>${task.status}</td>
                            <td>${task.assignedcToID}</td>
                            <td>${task.notes}</td>
                            <td><fmt:formatDate value="${task.updatedAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                            <td class="text-center">
                                <form action="${pageContext.request.contextPath}/admin/housekeeping" method="post" style="display: flex; align-items: center; gap: 10px;">
                                    <input type="hidden" name="action" value="edit" />
                                    <input type="hidden" name="taskId" value="${task.id}" />

                                    <select name="newStatus" class="form-select form-select-sm" style="width: auto;">
                                        <option value="PENDING" ${task.status == 'PENDING' ? 'selected' : ''}>PENDING</option>
                                        <option value="IN_PROGRESS" ${task.status == 'IN_PROGRESS' ? 'selected' : ''}>IN_PROGRESS</option>
                                        <option value="DONE" ${task.status == 'DONE' ? 'selected' : ''}>DONE</option>
                                    </select>

                                    <button type="submit" class="btn btn-sm btn-warning" title="Edit">
                                        <i class="fa fa-edit"></i>
                                    </button>
                                </form>
                                <form action="${pageContext.request.contextPath}/admin/housekeeping" method="post" style="display:inline;">
                                    <input type="hidden" name="action" value="delete"/>
                                    <input type="hidden" name="taskId" value="${task.id}"/>
                                    <button type="submit" class="btn btn-sm btn-danger" title="Delete"
                                            onclick="return confirm('Are you sure you want to delete this task?');">
                                        <i class="fa fa-trash"></i>
                                    </button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty tasks}">
                        <tr>
                            <td colspan="6" class="text-center">No housekeeping tasks found.</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>
                   
<!-- endcode -->


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