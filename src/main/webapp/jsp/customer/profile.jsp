<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>My Profile</title>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
        <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
        <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js"></script>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

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
                padding: 0;
                position: fixed;
                height: 100vh;
                z-index: 1000;
                transition: transform 0.3s ease;
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
            }

            /* Profile Card */
            .profile-card {
                background: rgba(255, 255, 255, 0.95);
                backdrop-filter: blur(10px);
                border-radius: 20px;
                box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
                padding: 30px;
                margin-bottom: 25px;
                border: 1px solid rgba(255, 255, 255, 0.2);
            }

            .profile-header {
                display: flex;
                align-items: center;
                margin-bottom: 30px;
                padding-bottom: 20px;
                border-bottom: 2px solid #f8f9fa;
            }

            .profile-avatar {
                width: 80px;
                height: 80px;
                border-radius: 50%;
                background: linear-gradient(135deg, #667eea, #764ba2);
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                font-size: 2rem;
                margin-right: 20px;
                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
            }

            .profile-info h3 {
                font-size: 1.5rem;
                font-weight: 600;
                color: #495057;
                margin-bottom: 5px;
            }

            .profile-info p {
                color: #6c757d;
                margin-bottom: 0;
            }

            .form-section {
                margin-bottom: 30px;
            }

            .section-title {
                font-size: 1.2rem;
                font-weight: 600;
                color: #495057;
                margin-bottom: 15px;
                display: flex;
                align-items: center;
            }

            .section-title i {
                margin-right: 10px;
                color: #667eea;
            }

            .form-group {
                margin-bottom: 20px;
            }

            .form-group label {
                font-weight: 600;
                color: #495057;
                margin-bottom: 8px;
                display: block;
            }

            .form-control {
                border: 2px solid #e9ecef;
                border-radius: 10px;
                padding: 12px 15px;
                font-size: 1rem;
                transition: all 0.3s ease;
                background: rgba(255, 255, 255, 0.9);
            }

            .form-control:focus {
                border-color: #667eea;
                box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
                background: white;
            }

            .btn {
                padding: 12px 25px;
                border: none;
                border-radius: 25px;
                font-size: 0.9rem;
                font-weight: 600;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                gap: 8px;
                cursor: pointer;
                transition: all 0.3s ease;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }

            .btn-primary {
                background: linear-gradient(135deg, #667eea, #764ba2);
                color: white;
            }

            .btn-primary:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 20px rgba(102, 126, 234, 0.3);
            }

            .btn-secondary {
                background: linear-gradient(135deg, #6c757d, #5a6268);
                color: white;
            }

            .btn-secondary:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 20px rgba(108, 117, 125, 0.3);
            }

            .btn-success {
                background: linear-gradient(135deg, #28a745, #20c997);
                color: white;
            }

            .btn-success:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 20px rgba(40, 167, 69, 0.3);
            }

            /* Alert Messages */
            .alert {
                padding: 15px 20px;
                margin-bottom: 20px;
                border-radius: 10px;
                border: none;
                font-weight: 500;
                display: block;

            }

            .alert-success {
                background: linear-gradient(135deg, #d4edda, #c3e6cb);
                color: #155724;
                border-left: 4px solid #28a745;
            }

            .alert-danger {
                background: linear-gradient(135deg, #f8d7da, #f5c6cb);
                color: #721c24;
                border-left: 4px solid #dc3545;
            }

            .alert-info {
                background: linear-gradient(135deg, #d1ecf1, #bee5eb);
                color: #0c5460;
                border-left: 4px solid #17a2b8;
            }

            /* Email Verification Section */
            .email-verification {
                background: linear-gradient(135deg, rgba(23, 162, 184, 0.1), rgba(23, 162, 184, 0.05));
                padding: 20px;
                border-radius: 15px;
                border-left: 4px solid #17a2b8;
                margin-bottom: 20px;
            }

            .verification-status {
                display: flex;
                align-items: center;
                margin-bottom: 15px;
            }

            .verification-status i {
                margin-right: 10px;
                font-size: 1.2rem;
            }

            .status-verified {
                color: #28a745;
            }

            .status-pending {
                color: #ffc107;
            }

            .status-unverified {
                color: #dc3545;
            }

            /* Modal Styles */
            .modal-content {
                border-radius: 20px;
                border: none;
                box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            }

            .modal-header {
                background: linear-gradient(135deg, #667eea, #764ba2);
                color: white;
                border-radius: 20px 20px 0 0;
                padding: 20px 30px;
                border-bottom: none;
            }

            .modal-header h5 {
                margin: 0;
                font-weight: 600;
            }

            .modal-body {
                padding: 30px;
            }

            .code-input {
                display: flex;
                gap: 10px;
                justify-content: center;
                margin: 20px 0;
            }

            .code-input input {
                width: 45px;
                height: 45px;
                text-align: center;
                font-size: 1.2rem;
                font-weight: 600;
                border: 2px solid #e9ecef;
                border-radius: 10px;
                background: rgba(255, 255, 255, 0.9);
                transition: all 0.3s ease;
            }

            .code-input input:focus {
                border-color: #667eea;
                box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
                background: white;
            }

            .timer {
                text-align: center;
                margin: 15px 0;
                font-size: 1.1rem;
                color: #6c757d;
            }

            .timer.expired {
                color: #dc3545;
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

                .profile-header {
                    flex-direction: column;
                    text-align: center;
                }

                .profile-avatar {
                    margin-right: 0;
                    margin-bottom: 15px;
                }

                .content-header {
                    padding: 25px 20px;
                }

                .content-header h2 {
                    font-size: 1.6rem;
                }

                .profile-card {
                    padding: 25px 20px;
                }

                .code-input {
                    flex-wrap: wrap;
                    gap: 8px;
                }

                .code-input input {
                    width: 40px;
                    height: 40px;
                }
            }

            /* Sidebar overlay for mobile */
            .sidebar-overlay {
                display: none;
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0, 0, 0, 0.5);
                z-index: 999;
            }

            .sidebar-overlay.active {
                display: block;
            }
            .nav-link{
                color: white;
            }
            .form-label{
                color: white;
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
                    <a href="${pageContext.request.contextPath}/customer/profile"  class="active">
                        <i class="fas fa-user-edit"></i>
                        <span>User Profile</span>
                    </a>
                </li>



                    <li>
                       <a class="dropdown-item" href="${pageContext.request.contextPath}/customer/services" >
                                                <i class="fa fa-concierge-bell"></i> Book Services
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
                <div class="container py-4">
                    <h2 class="mb-3"style="color:#ffc107 ">My Profile</h2>
                    
                    <c:if test="${not empty sessionScope.success}">
                        <div class="alert alert-success">${sessionScope.success}</div>
                        <c:remove var="success" scope="session"/>
                    </c:if>
                    <c:if test="${not empty sessionScope.error}">
                        <div class="alert alert-danger">${sessionScope.error}</div>
                        <c:remove var="error" scope="session"/>
                    </c:if>
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger">${error}</div>
                    </c:if>
                    <c:set var="form" value="${formData != null ? formData : customer}" />
                    
                    <ul class="nav nav-tabs" id="profileTabs" role="tablist">
                        <li class="nav-item" role="presentation">
                            <button class="nav-link active" id="overview-tab" data-bs-toggle="tab" data-bs-target="#overview" type="button" role="tab">Overview</button>
                        </li>
                      
                        <li class="nav-item" role="presentation">
                            <button class="nav-link" id="security-tab" data-bs-toggle="tab" data-bs-target="#security" type="button" role="tab">Security</button>
                        </li>
                    </ul>

                    <div class="tab-content p-3 border border-top-0" id="profileTabsContent">
                        <div class="tab-pane fade show active" id="overview" role="tabpanel">
                            <div class="card mb-3">
                                <div class="card-body">
                                    <h5 class="card-title mb-3">${customer.fullName}</h5>
                                    <p class="mb-1"><strong>Email:</strong> ${customer.email}</p>
                                    <p class="mb-1"><strong>Phone:</strong> ${customer.phone}</p>
                                    <p class="mb-1"><strong>Gender:</strong> ${customer.gender}</p>
                                    <p class="mb-1"><strong>Address:</strong>
                                        <c:choose>
                                            <c:when test="${not empty customer.fullAddress}">
                                                ${customer.fullAddress}
                                            </c:when>
                                            <c:otherwise>Not provided</c:otherwise>
                                        </c:choose>
                                    </p>
                                    <p class="mb-1"><strong>Membership:</strong> ${customer.membershipLevel}</p>
                                    <p class="mb-0"><strong>Loyalty Points:</strong> ${customer.loyaltyPoints}</p>
                                </div>
                            </div>

                            <h2 class="mb-3" style="color: lightcoral">Edit Profile</h2>   
                            
                            <form action="${pageContext.request.contextPath}/customer/update-profile" method="post" class="row g-3" novalidate>
                                <input type="hidden" name="id" value="${customer.id}" />
                                <div class="col-md-6">
                                    <label class="form-label">Full Name</label>
                                    <input type="text" class="form-control" name="fullName" value="${form.fullName}" required />
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Email</label>
                                    <input type="email" class="form-control" name="email" value="${form.email}" required />
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Phone</label>
                                    <input type="text" class="form-control" name="phone" value="${form.phone}" pattern="0\\d{9}" required />
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Date of Birth</label>
                                    <input type="date" class="form-control" name="dateOfBirth" value="${form.dateOfBirth}" />
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Gender</label>
                                    <select class="form-select" name="gender">

                                        <option value="MALE" ${form.gender == 'MALE' ? 'selected' : ''}>Male</option>
                                        <option value="FEMALE" ${form.gender == 'FEMALE' ? 'selected' : ''}>Female</option>
                                        <option value="OTHER" ${form.gender == 'OTHER' ? 'selected' : ''}>Other</option>
                                    </select>
                                </div>
                                <div class="col-md-12">
                                    <label class="form-label">Address</label>
                                    <input type="text" class="form-control" name="address" value="${form.address}" maxlength="30" pattern=".{1,30}" />                </div>
                                <div class="col-md-6">
                                    <label class="form-label">City</label>
                                    <input type="text" class="form-control" name="city" value="${form.city}" maxlength="30" pattern=".{1,30}" />
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Country</label>
                                    <input type="text" class="form-control" name="country" value="${form.country}" maxlength="30" pattern=".{1,30}"/>

                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Loyalty Points</label>
                                    <input type="text" class="form-control" value="${customer.loyaltyPoints}" readonly />
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Membership Level</label>
                                    <input type="text" class="form-control" value="${customer.membershipLevel}" readonly />
                                </div>
                                <div class="col-12">
                                    <button class="btn btn-primary" type="submit">Save</button>
                                </div>
                            </form>
                        </div>
                        <div class="tab-pane fade" id="reservations" role="tabpanel">
                            <table class="table table-striped">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Room</th>
                                        <th>Check In</th>
                                        <th>Check Out</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="res" items="${reservations}">
                                        <tr>
                                            <td>${res.id}</td>
                                            <td>${res.roomNumber}</td>
                                            <td><fmt:formatDate value="${res.checkIn}" pattern="yyyy-MM-dd"/></td>
                                            <td><fmt:formatDate value="${res.checkOut}" pattern="yyyy-MM-dd"/></td>
                                            <td>${res.status}</td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                                               <div class="tab-pane fade" id="security" role="tabpanel">
                            <form action="${pageContext.request.contextPath}/customer/change-password" method="post" class="row g-3" novalidate>
                                <div class="col-md-6">
                                    <label class="form-label">Current Password</label>
                                    <input type="password" class="form-control" name="currentPassword" required />
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">New Password</label>
                                    <input type="password" class="form-control" name="newPassword" required />
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Confirm Password</label>
                                    <input type="password" class="form-control" name="confirmPassword" required />
                                </div>
                                <div class="col-12">
                                    <button class="btn btn-primary" type="submit">Change Password</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </main>
  <script>
            document.addEventListener('DOMContentLoaded', function() {
                if (window.location.hash) {
                    const trigger = document.querySelector('button[data-bs-target="' + window.location.hash + '"]');
                    if (trigger) {
                        new bootstrap.Tab(trigger).show();
                    }
                }

                const triggers = document.querySelectorAll('#profileTabs button[data-bs-toggle="tab"]');
                triggers.forEach(function(el) {
                    el.addEventListener('shown.bs.tab', function(event) {
                        const target = event.target.getAttribute('data-bs-target');
                        if (history.replaceState) {
                            history.replaceState(null, null, target);
                        } else {
                            window.location.hash = target;
                        }
                    });
                });
            });
        </script>
    </body>
</html>