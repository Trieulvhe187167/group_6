<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Home</a></li>
            <li class="breadcrumb-item active">Service Management</li>
        </ol>
    </nav>

    <div class="card mb-4">
        <div class="card-body">
            <form method="get" action="${pageContext.request.contextPath}/admin/services" class="form-inline">
                <input type="text" name="search" class="form-control mr-2" placeholder="Search" value="${search}">
                <select name="status" class="form-control mr-2">
                    <option value="">All Status</option>
                    <option value="ACTIVE" ${status == 'ACTIVE' ? 'selected' : ''}>Active</option>
                    <option value="INACTIVE" ${status == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
                </select>
                <button type="submit" class="btn btn-primary mr-2">Filter</button>
                <c:if test="${not empty search || not empty status}">
                    <a href="${pageContext.request.contextPath}/admin/services" class="btn btn-secondary">Clear</a>
                </c:if>
                <a href="${pageContext.request.contextPath}/admin/services?action=add" class="btn btn-success ml-auto">
                    <i class="fas fa-plus"></i> Add New Service
                </a>
            </form>
        </div>
    </div>

    <div class="table-container">
        <c:choose>
            <c:when test="${not empty services}">
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th width="5%">#</th>
                                <th width="35%">Name</th>
                                <th width="15%">Price</th>
                                <th width="15%">Status</th>
                                <th width="30%">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="s" items="${services}" varStatus="st">
                                <tr>
                                    <td>${(currentPage - 1) * recordsPerPage + st.count}</td>
                                    <td>
                                        <strong>${s.name}</strong>
                                        <c:if test="${not empty s.description}">
                                            <br><small class="text-muted">${s.description}</small>
                                        </c:if>
                                    </td><td><fmt:formatNumber value="${s.price}"  />đ</td>
                                    <td>
                                        <span class="badge ${s.status == 'ACTIVE' ? 'badge-success' : 'badge-secondary'}">${s.status}</span>
                                    </td>
                                    <td>
                                        <div class="btn-group btn-group-sm">
                                            <a href="${pageContext.request.contextPath}/admin/services?action=view&id=${s.id}" class="btn btn-info" title="View"><i class="fas fa-eye"></i></a>
                                            <a href="${pageContext.request.contextPath}/admin/services?action=edit&id=${s.id}" class="btn btn-warning" title="Edit"><i class="fas fa-edit"></i></a>
                                            <button type="button" class="btn btn-danger" onclick="confirmDelete(${s.id}, '${s.name}')" title="Delete"><i class="fas fa-trash"></i></button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <c:if test="${totalPages > 1}">
                    <nav aria-label="Page navigation">
                        <ul class="pagination justify-content-center">
                            <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                <a class="page-link" href="?page=${currentPage - 1}&search=${search}&status=${status}">Previous</a>
                            </li>
                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <li class="page-item ${i == currentPage ? 'active' : ''}">
                                    <a class="page-link" href="?page=${i}&search=${search}&status=${status}">${i}</a>
                                </li>
                            </c:forEach>
                            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                <a class="page-link" href="?page=${currentPage + 1}&search=${search}&status=${status}">Next</a>
                            </li>
                        </ul>
                    </nav>
                </c:if>
            </c:when>
            <c:otherwise>
                <div class="text-center py-5">
                    <h4 class="text-muted">No services found</h4>
                    <a href="${pageContext.request.contextPath}/admin/services?action=add" class="btn btn-primary">
                        <i class="fas fa-plus"></i> Add New Service
                    </a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<div class="modal fade" id="deleteModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header"><h5 class="modal-title">Confirm Delete</h5>
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