<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/housekeeper-dashboard">Home</a></li>
            <li class="breadcrumb-item active">My Profile</li>
        </ol>
    </nav>

    <h1 class="mb-4">My Profile</h1>
   
    <div class="card mb-4">
        <div class="card-body">
            <div class="row">
                <div class="col-md-3 text-center">
                    <div class="avatar-circle mx-auto mb-3" style="width:100px;height:100px;background:#6c757d;color:white;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:36px;">
                        ${user.initial}
                    </div>
                    <h5>${user.fullName}</h5>
                    <span class="badge ${user.roleBadgeClass}">${user.roleDisplayName}</span>
                </div>
                <div class="col-md-9">
                    <table class="table table-sm table-borderless">
                        <tr>
                            <th width="30%">Username:</th>
                            <td>${user.username}</td>
                        </tr>
                        <tr>
                            <th>Email:</th>
                            <td>${user.email}</td>
                        </tr>
                        <tr>
                            <th>Phone:</th>
                            <td>${user.phone}</td>
                        </tr>
                         <tr>
                            <th>Date of Birth:</th>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty user.dateOfBirth}">
                                        <fmt:formatDate value="${user.dateOfBirth}" pattern="dd/MM/yyyy"/>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted">Not provided</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                        <tr>
                            <th>Address:</th>
                            <td>${empty user.address ? 'Not provided' : user.address}</td>
                        </tr>
                        <tr>
                            <th>City:</th>
                            <td>${empty user.city ? 'Not provided' : user.city}</td>
                        </tr>
                        <tr>
                            <th>Country:</th>
                            <td>${empty user.country ? 'Not provided' : user.country}</td>
                        </tr>
                        <tr>
                            <th>Department:</th>
                            <td>${user.department}</td>
                        </tr>
                        <tr>
                            <th>Hire Date:</th>
                            <td><fmt:formatDate value="${user.hireDate}" pattern="dd/MM/yyyy"/></td>
                        </tr>
                          <tr>
                            <th>Salary:</th>
                            <td>${user.formattedSalary}</td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>
    </div>
                         <!-- Alert Messages -->
    <c:if test="${not empty sessionScope.success}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            ${sessionScope.success}
            <button type="button" class="close" data-dismiss="alert">
                <span>&times;</span>
            </button>
        </div>
        <c:remove var="success" scope="session"/>
    </c:if>

    <c:if test="${not empty sessionScope.error}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            ${sessionScope.error}
            <button type="button" class="close" data-dismiss="alert">
                <span>&times;</span>
            </button>
        </div>
        <c:remove var="error" scope="session"/>
    </c:if>
                         <div class="card mb-4" id="security">
        <div class="card-header">
            <h5 class="mb-0">Change Password</h5>
        </div>
        <div class="card-body">
            <form action="${pageContext.request.contextPath}/housekeeper/change-password" method="post" class="row g-3" novalidate>
                <div class="col-md-4">
                    <label class="form-label">Current Password</label>
                    <input type="password" class="form-control" name="currentPassword" required />
                </div>
                <div class="col-md-4">
                    <label class="form-label">New Password</label>
                    <input type="password" class="form-control" name="newPassword" required />
                </div>
                <div class="col-md-4">
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