<%-- 
    Document   : support-form
    Created on : 1 thg 8, 2025, 13:29:03
    Author     : ASUS
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>



<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Request Support</title>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
        <!--        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css" />-->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }

            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
            }

            .dashboard-container {
                display: flex;
                min-height: 100vh;
            }

            /* Sidebar Styles */
            .sidebar {
                width: 280px;
                background: rgba(255, 255, 255, 0.95);
                backdrop-filter: blur(10px);
                box-shadow: 4px 0 20px rgba(0, 0, 0, 0.1);
                position: fixed;
                height: 100vh;
                z-index: 1000;
                transition: transform 0.3s ease;
                overflow-y: auto;
            }

            .sidebar-header {
                padding: 30px 25px;
                background: linear-gradient(135deg, #667eea, #764ba2);
                color: white;
                text-align: center;
                border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            }

            .sidebar-header h3 {
                font-size: 1.4rem;
                font-weight: 600;
                margin-bottom: 5px;
            }

            .sidebar-header p {
                font-size: 0.9rem;
                opacity: 0.8;
            }

            .sidebar-menu {
                list-style: none;
                padding: 20px 0;
            }

            .sidebar-menu li {
                margin: 0;
            }

            .sidebar-menu a {
                display: flex;
                align-items: center;
                padding: 15px 25px;
                color: #495057;
                text-decoration: none;
                transition: all 0.3s ease;
                border-left: 3px solid transparent;
            }

            .sidebar-menu a:hover {
                background: linear-gradient(90deg, rgba(102, 126, 234, 0.1), transparent);
                border-left-color: #667eea;
                color: #667eea;
            }

            .sidebar-menu a.active {
                background: linear-gradient(90deg, rgba(102, 126, 234, 0.15), transparent);
                border-left-color: #667eea;
                color: #667eea;
                font-weight: 600;
            }

            .sidebar-menu i {
                width: 20px;
                margin-right: 15px;
                font-size: 1.1rem;
            }

            .menu-divider {
                height: 1px;
                background: linear-gradient(90deg, transparent, #e9ecef, transparent);
                margin: 15px 0;
            }

            /* Mobile Toggle */
            .mobile-toggle {
                display: none;
                position: fixed;
                top: 20px;
                left: 20px;
                z-index: 1001;
                background: #667eea;
                color: white;
                border: none;
                border-radius: 50%;
                width: 50px;
                height: 50px;
                font-size: 1.2rem;
                cursor: pointer;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
                transition: all 0.3s ease;
            }

            .mobile-toggle:hover {
                background: #764ba2;
                transform: scale(1.05);
            }

            /* Main Content */
            .main-content {
                flex: 1;
                margin-left: 280px;
                padding: 40px;
                min-height: 100vh;
                transition: margin-left 0.3s ease;
            }

            .content-header {
                background: rgba(255, 255, 255, 0.9);
                backdrop-filter: blur(10px);
                border-radius: 15px;
                padding: 30px;
                margin-bottom: 30px;
                box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            }

            .content-header h2 {
                color: #343a40;
                font-size: 2rem;
                font-weight: 700;
                margin-bottom: 10px;
            }

            .content-header p {
                color: #6c757d;
                font-size: 1.1rem;
                margin-bottom: 0;
            }

            /* Feedback Form */
            .feedback-form-container {
                background: rgba(255, 255, 255, 0.9);
                backdrop-filter: blur(10px);
                border-radius: 20px;
                padding: 40px;
                box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
                max-width: 800px;
                margin: 0 auto;
            }

            .form-group {
                margin-bottom: 30px;
            }

            .form-group label {
                display: block;
                margin-bottom: 10px;
                font-weight: 600;
                color: #495057;
                font-size: 1.1rem;
            }

            .form-control {
                width: 100%;
                padding: 15px;
                border: 2px solid #e9ecef;
                border-radius: 10px;
                font-size: 1rem;
                transition: border-color 0.3s ease;
            }

            .form-control:focus {
                outline: none;
                border-color: #667eea;
                box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
            }

            .rating-section {
                margin-bottom: 30px;
            }

            .rating-stars {
                display: flex;
                gap: 10px;
                margin-top: 15px;
            }

            .star {
                font-size: 2rem;
                color: #ddd;
                cursor: pointer;
                transition: color 0.3s ease;
            }

            .star:hover,
            .star.active {
                color: #ffc107;
            }

            .star.filled {
                color: #ffc107;
            }

            .rating-text {
                margin-top: 10px;
                font-weight: 600;
                color: #495057;
            }

            .btn {
                display: inline-flex;
                align-items: center;
                padding: 15px 30px;
                border-radius: 10px;
                text-decoration: none;
                font-weight: 600;
                transition: all 0.3s ease;
                border: none;
                cursor: pointer;
                font-size: 1rem;
            }

            .btn-primary {
                background: linear-gradient(135deg, #667eea, #764ba2);
                color: white;
            }

            .btn-primary:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 20px rgba(102, 126, 234, 0.3);
                color: white;
            }

            .btn-secondary {
                background: linear-gradient(135deg, #6c757d, #495057);
                color: white;
            }

            .btn-secondary:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 20px rgba(108, 117, 125, 0.3);
                color: white;
            }

            .btn i {
                margin-right: 8px;
            }

            .alert {
                padding: 15px 20px;
                border-radius: 10px;
                margin-bottom: 20px;
                border: none;
            }

            .alert-success {
                background: linear-gradient(135deg, #28a745, #20c997);
                color: white;
            }

            .alert-danger {
                background: linear-gradient(135deg, #dc3545, #c82333);
                color: white;
            }

            .reservation-info {
                background: rgba(102, 126, 234, 0.05);
                border-radius: 10px;
                padding: 20px;
                margin-bottom: 20px;
                border-left: 4px solid #667eea;
            }

            .reservation-info h5 {
                color: #495057;
                margin-bottom: 15px;
                font-weight: 600;
            }

            .info-item {
                display: flex;
                align-items: center;
                margin-bottom: 10px;
            }

            .info-item i {
                color: #667eea;
                margin-right: 10px;
                width: 20px;
            }

            .info-label {
                font-weight: 600;
                color: #495057;
                margin-right: 8px;
            }

            .info-value {
                color: #6c757d;
            }

            /* Responsive Design */
            @media (max-width: 768px) {
                .mobile-toggle {
                    display: block;
                }

                .sidebar {
                    transform: translateX(-100%);
                }

                .sidebar.active {
                    transform: translateX(0);
                }

                .main-content {
                    margin-left: 0;
                    padding: 80px 20px 40px;
                }

                .feedback-form-container {
                    padding: 25px 20px;
                }

                .content-header {
                    padding: 25px 20px;
                }

                .content-header h2 {
                    font-size: 1.6rem;
                }

                .rating-stars {
                    justify-content: center;
                }

                .star {
                    font-size: 1.8rem;
                }
            }
        </style>
    </head>
    <body>

        <!-- Mobile Toggle Button -->
        <button class="mobile-toggle" onclick="toggleSidebar()">
            <i class="fas fa-bars"></i>
        </button>

        <!-- Sidebar Overlay -->
        <div class="sidebar-overlay" onclick="toggleSidebar()"></div>

        <div class="dashboard-container">
            <!-- Sidebar -->
            <nav class="sidebar" id="sidebar">
                <div class="sidebar-header">
                    <h3><i class="fas fa-user-circle"></i> Customer Panel</h3>
                    <p>Welcome back!</p>
                </div>
                <ul class="sidebar-menu">
                    <li>
                        <a href="${pageContext.request.contextPath}/customer/bookings">
                            <i class="fas fa-calendar-check"></i>
                            <span>My Bookings</span>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/customer/history">
                            <i class="fas fa-history"></i>
                            <span>Booking History</span>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/customer/your-feedback">
                            <i class="fas fa-comments"></i>
                            <span>My Feedback</span>
                        </a>
                    </li>
                    <div class="menu-divider"></div>
                    <li>
                        <a href="${pageContext.request.contextPath}/customer/profile">
                            <i class="fas fa-user-edit"></i>
                            <span>User Profile</span>
                        </a>
                    </li>
                    <li>
                        <a class="dropdown-item" href="${pageContext.request.contextPath}/customer/services" >
                            <i class="fa fa-concierge-bell"></i> Book Services
                        </a>
                    </li>
                    <li>
                        <a class="dropdown-item" href="${pageContext.request.contextPath}/customer/support" class="active">
                            <i class="fa fa-concierge-bell"></i> Support
                        </a>
                    </li>
                    <div class="menu-divider"></div>
                    <li>
                        <a href="/index.jsp">
                            <i class="fas fa-home"></i>
                            <span>Homepage</span>
                        </a>
                    </li>

                    <div class="menu-divider"></div>
                    <li>
                        <a href="${pageContext.request.contextPath}/LogoutServlet" style="color: #dc3545;">
                            <i class="fas fa-sign-out-alt"></i>
                            <span>Logout</span>
                        </a>
                    </li>
                </ul>
            </nav>

            <!-- Main Content -->
            <main class="main-content">
                <%-- Error --%>
                <c:if test="${not empty error}">
                    <div class="alert alert-danger mt-3">
                        ${error}
                    </div>
                </c:if>

                <div class="content-header">
                    <h2><i class="fas fa-comments"></i> Support Request Form </h2>
                    <p>Add your form for request support</p>
                </div>

                <div style="background-color: white; padding: 30px; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); margin-bottom: 30px;">



                    <h4 class="card-title mb-4">Submit a Support Request</h4>

                    <form action="${pageContext.request.contextPath}/customer/support" method="post">
                        <input type="hidden" name="action" value="create" />

                        <div class="mb-3">
                            <label for="roomId" class="form-label">Room</label>
                            <select name="roomId" id="roomId" class="form-select" required>
                                <c:forEach var="room" items="${occupiedRooms}">
                                    <option value="${room.id}" 
                                            <c:if test="${room.id == selectedRoomId}">selected</c:if>>
                                        ${room.roomNumber}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label for="title" class="form-label">Title</label>
                            <input type="text" name="title" id="title" class="form-control" value="${fn:escapeXml(inputTitle)}" 
                                   pattern="[A-Za-zÀ-ỹ\s]+"
                                   oninput="this.value = this.value.replace(/[^A-Za-zÀ-ỹ\s]/g, '')"
                                   title="Only letters and spaces allowed"
                                   required />
                        </div>

                        <div class="mb-3">
                            <label for="description" class="form-label">Description</label>
                            <textarea name="description" id="description" class="form-control" rows="5" required>${fn:escapeXml(inputDescription)}</textarea>
                        </div>

                        <div class="d-flex justify-content-between">
                            <a href="${pageContext.request.contextPath}/customer/support" class="btn btn-primary mb-3">
                                <i class="fas fa-backward"></i>Back to My Requests
                            </a>
                            <button type="submit" class="btn btn-primary mb-3">
                                <i class="fas fa-paper-plane"></i> Submit Request
                            </button>
                        </div>
                    </form>

                </div>
            </main>
        </div>
        <!-- Các phần hỗ trợ giao diện -->
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
        <!-- FontAwesome for icons -->
        <script src="https://kit.fontawesome.com/a076d05399.js" crossorigin="anonymous"></script>

    </body>
</html>

