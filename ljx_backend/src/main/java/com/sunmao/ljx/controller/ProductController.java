package com.sunmao.ljx.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.sunmao.ljx.common.Result;
import com.sunmao.ljx.entity.Product;
import com.sunmao.ljx.entity.ProductOrder;
import com.sunmao.ljx.mapper.ProductOrderMapper;
import com.sunmao.ljx.service.ProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/product")
public class ProductController {

    @Autowired
    private ProductService productService;

    @Autowired
    private ProductOrderMapper productOrderMapper;

    @GetMapping("/list")
    public Result<List<Product>> list(@RequestParam(defaultValue = "1") Integer categoryId) {
        List<Product> list;
        if (categoryId == 1) {
            list = productService.list(new LambdaQueryWrapper<Product>()
                    .eq(Product::getStatus, 1)
                    .orderByDesc(Product::getCreateTime));
        } else {
            list = productService.list(new LambdaQueryWrapper<Product>()
                    .eq(Product::getCategoryId, categoryId)
                    .eq(Product::getStatus, 1)
                    .orderByDesc(Product::getCreateTime));
        }
        return Result.success(list);
    }

    @GetMapping("/detail/{productId}")
    public Result<Product> detail(@PathVariable Integer productId) {
        Product product = productService.getById(productId);
        return Result.success(product);
    }

    @GetMapping("/search")
    public Result<List<Product>> search(@RequestParam String keyword) {
        List<Product> list = productService.list(new LambdaQueryWrapper<Product>()
                .like(Product::getProductName, keyword)
                .eq(Product::getStatus, 1));
        return Result.success(list);
    }

    @PostMapping("/order/create")
    public Result<ProductOrder> createOrder(@RequestParam Integer productId,
                                             @RequestParam Integer userId,
                                             @RequestParam(defaultValue = "1") Integer quantity) {
        Product product = productService.getById(productId);
        if (product == null) {
            return Result.error("商品不存在");
        }
        ProductOrder order = new ProductOrder();
        order.setProductId(productId);
        order.setProductName(product.getProductName());
        order.setUserId(userId);
        order.setQuantity(quantity);
        order.setTotalPrice(product.getPrice().multiply(new BigDecimal(quantity)));
        order.setStatus(0);
        order.setCreateTime(LocalDateTime.now());
        productOrderMapper.insert(order);
        return Result.success(order);
    }

    @GetMapping("/order/my")
    public Result<List<ProductOrder>> myOrders(@RequestParam Integer userId) {
        List<ProductOrder> orders = productOrderMapper.selectList(
                new LambdaQueryWrapper<ProductOrder>()
                        .eq(ProductOrder::getUserId, userId)
                        .orderByDesc(ProductOrder::getCreateTime));
        return Result.success(orders);
    }

    /**
     * 取消订单：仅 status=0（待支付）可取消
     * 状态码：0待支付 / 1已支付 / 2已发货 / 3已完成 / 4已取消
     */
    @PostMapping("/order/cancel")
    public Result<String> cancelOrder(@RequestParam Integer orderId,
                                      @RequestParam Integer userId) {
        ProductOrder order = productOrderMapper.selectById(orderId);
        if (order == null) {
            return Result.error("订单不存在");
        }
        if (!order.getUserId().equals(userId)) {
            return Result.error("无权操作此订单");
        }
        if (order.getStatus() == null || order.getStatus() != 0) {
            return Result.error("订单已支付，无法取消");
        }
        order.setStatus(4);
        productOrderMapper.updateById(order);
        return Result.success("取消成功");
    }

    /** 售后期天数：已完成订单超过此天数才允许删除 */
    private static final long AFTER_SALES_DAYS = 7L;

    /**
     * 删除订单（物理删除）：仅允许以下两种情况
     * ① status=4（已取消）——任何时候都可删
     * ② status=3（已完成）且 createTime 距今超过 7 天（售后期外）
     * 其他状态（待支付/待发货/待收货/已发货/在售后期内的已完成）一律拒绝
     */
    @PostMapping("/order/delete")
    public Result<String> deleteOrder(@RequestParam Integer orderId,
                                      @RequestParam Integer userId) {
        ProductOrder order = productOrderMapper.selectById(orderId);
        if (order == null) {
            return Result.error("订单不存在");
        }
        if (!order.getUserId().equals(userId)) {
            return Result.error("无权操作此订单");
        }
        int status = order.getStatus() == null ? 0 : order.getStatus();
        if (status == 4) {
            // 已取消：可删
        } else if (status == 3) {
            // 已完成：必须超过售后期
            if (order.getCreateTime() == null) {
                return Result.error("订单信息不完整，无法删除");
            }
            long days = java.time.Duration.between(order.getCreateTime(), LocalDateTime.now()).toDays();
            if (days < AFTER_SALES_DAYS) {
                return Result.error("订单仍在售后期内（" + AFTER_SALES_DAYS + "天），暂不可删除");
            }
        } else {
            return Result.error("订单进行中，无法删除");
        }
        productOrderMapper.deleteById(orderId);
        return Result.success("删除成功");
    }
}
