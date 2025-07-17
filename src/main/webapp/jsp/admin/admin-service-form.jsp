<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container-fluid">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Home</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/services">Service Management</a></li>
            <li class="breadcrumb-item active">${isEdit ? 'Edit' : 'Add'} Service</li>
        </ol>
    </nav>

    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1>${isEdit ? 'Edit' : 'Add New'} Service</h1>
        <a href="${pageContext.request.contextPath}/admin/services" class="btn btn-secondary">
            <i class="fas fa-arrow-left"></i> Back to List
        </a>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            ${error}
            <button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>
        </div>
    </c:if>

    <div class="card">
        <div class="card-body">
            <form method="post" action="${pageContext.request.contextPath}/admin/services">
                <input type="hidden" name="action" value="${isEdit ? 'update' : 'create'}">
                <c:if test="${isEdit}">
                    <input type="hidden" name="id" value="${service.id}">
                </c:if>

                <div class="form-group">
                    <label for="name">Name <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" id="name" name="name" value="${service.name}" required>
                </div>

                <div class="form-group">
                    <label for="description">Description</label>
                    <textarea class="form-control" id="description" name="description" rows="4">${service.description}</textarea>
                </div>

                <div class="form-group">
                    <label for="price">Price <span class="text-danger">*</span></label>
                    <input type="number" step="0.01" class="form-control" id="price" name="price" value="${service.price}" required>
                </div>

                <div class="form-group">
                    <label for="status">Status</label>
                    <select class="form-control" id="status" name="status">
                        <option value="ACTIVE" ${service.status == 'ACTIVE' ? 'selected' : ''}>Active</option>
                        <option value="INACTIVE" ${service.status == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
                    </select>
                </div>

                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save"></i> ${isEdit ? 'Update' : 'Create'} Service
                    </button>
                <a href="${pageContext.request.contextPath}/admin/services" class="btn btn-secondary">
                    <i class="fas fa-times"></i> Cancel
                </a>
            </form>
        </div>
    </div>
</div>