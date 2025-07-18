<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Home</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/services">Service Management</a></li>
            <li class="breadcrumb-item active">Service Details</li>
        </ol>
    </nav>

    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1>${service.name}</h1>
        <a href="${pageContext.request.contextPath}/admin/services" class="btn btn-secondary">
            <i class="fas fa-arrow-left"></i> Back to List
        </a>
    </div>

    <div class="card">
        <div class="card-body">
            <p><strong>Description:</strong> ${service.description}</p>
            <p><strong>Price:</strong> <fmt:formatNumber value="${service.price}" type="currency" /></p>
            <p><strong>Status:</strong> <span class="badge ${service.status == 'ACTIVE' ? 'badge-success' : 'badge-secondary'}">${service.status}</span></p>
            <p><strong>Created At:</strong> <fmt:formatDate value="${service.createdAt}" pattern="dd/MM/yyyy HH:mm"/></p>
        </div>
    </div>

    <div class="mt-3">
        <a href="${pageContext.request.contextPath}/admin/services?action=edit&id=${service.id}" class="btn btn-primary"><i class="fas fa-edit"></i> Edit</a>
        <button type="button" class="btn btn-danger" onclick="confirmDelete(${service.id}, '${service.name}')"><i class="fas fa-trash"></i> Delete</button>
    </div>
</div>

<div class="modal fade" id="deleteModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Confirm Delete</h5>
                <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to delete this service?</p>
                <p class="font-weight-bold" id="serviceName"></p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <form method="post" action="${pageContext.request.contextPath}/admin/services" style="display:inline;">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" id="deleteId">
                    <button type="submit" class="btn btn-danger">Delete</button>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    function confirmDelete(id, name) {
        document.getElementById('deleteId').value = id;
        document.getElementById('serviceName').textContent = name;
        $('#deleteModal').modal('show');
    }
</script>
}