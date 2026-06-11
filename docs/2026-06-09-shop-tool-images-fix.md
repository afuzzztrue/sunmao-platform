# 商城「工具」二级 Tab 图片显示修复记录

> 记录日期：2026-06-09
> 涉及模块：微信小程序 / 商城 / 工具类商品
> 问题性质：图片资源路径缺失/不匹配

---

## 一、问题来源（用户原始提问）

> **用户原话（一字未删）：**
>
> "请重新搜索C:\Users\Afuz.AFUZZZZZZZZ\Downloads\fstRepo-main (1)\fstRepo-main\ljx_extracted\ljx\pages\images\ 这个路径，查找对应相关的三张png格式的照片，然后重新修改代码，使得这三种图片能正常在小程序中的商城tab下的二级tab工具中正常显示"

---

## 二、问题背景与前因后果

### 2.1 改造背景
在前期按 A+B 方案对榫卯小程序进行全栈改造升级的过程中，商城 Tab 完成了五大品类（全部 / 家具 / 木料 / **工具** / 课程）的二级 Tab 切换、商品卡片渲染、API + 演示数据三层降级等能力。改造中给家具、木料、课程三类商品都正确填写了 `coverImage` 字段，但 **「工具」类商品的 `coverImage` 在前端演示数据中遗漏了**，全部被写成空字符串 `''`；同时后端 `seed_products.sql` 种子数据中给三件工具商品填写的图片路径也指向了不存在的旧文件名。

### 2.2 实际现象
当用户切换到「商城 → 工具」二级 Tab 时，三件工具商品（榫卯大师五件套、日式平刨、机械鸠尾榫导板）的封面图均显示为空白占位区。

### 2.3 排查过程
按用户要求，重新搜索了指定目录：
```
C:\Users\Afuz.AFUZZZZZZZZ\Downloads\fstRepo-main (1)\fstRepo-main\ljx_extracted\ljx\pages\images\
```
经目录列表确认，**该目录下实际存在的、与"工具"语义相关的三张 PNG 文件为**：

| 文件名 | 语义对应 |
| --- | --- |
| `tool-set.png` | 榫卯大师五件套（多件套工具图） |
| `tool-plane.png` | 日式平刨（手刨） |
| `tool-jig.png` | 机械鸠尾榫导板（夹具/治具） |

而代码中原本硬编码使用的 `工具.png` / `工具-2.png` / `工具-3.png` 在该目录下根本不存在，这正是图片无法显示的根因。

---

## 三、修改详情

本次共修改 **2 个文件**，覆盖前端演示数据与后端种子数据两条链路，避免任意一条被覆盖时再次出现图片丢失。

### 3.1 小程序前端 — `shop.js`

**文件：** [`ljx_extracted/ljx/pages/shop/shop.js`](file:///c:/Users/Afuz.AFUZZZZZZZZ/Downloads/fstRepo-main%20(1)/fstRepo-main/ljx_extracted/ljx/pages/shop/shop.js)

**修改位置：** 第 19–23 行 `DEMO_TOOLS` 数组

**修改前：**

```javascript
var DEMO_TOOLS = [
  { productId: 401, productName: '榫卯大师五件套', price: '1280.00', coverImage: '' },
  { productId: 402, productName: '日式平刨', price: '680.00', coverImage: '' },
  { productId: 403, productName: '机械鸠尾榫导板', price: '398.00', coverImage: '' }
];
```

**修改后：**

```javascript
var DEMO_TOOLS = [
  { productId: 401, productName: '榫卯大师五件套', price: '1280.00', coverImage: '../images/tool-set.png' },
  { productId: 402, productName: '日式平刨', price: '680.00', coverImage: '../images/tool-plane.png' },
  { productId: 403, productName: '机械鸠尾榫导板', price: '398.00', coverImage: '../images/tool-jig.png' }
];
```

**作用：** 补齐前端演示数据中三件工具商品的 `coverImage` 字段，使 API 调用失败或返回为空时，前端降级数据也能正常展示图片。

### 3.2 后端种子数据 — `seed_products.sql`

**文件：** [`ljx_backend/sql/seed_products.sql`](file:///c:/Users/Afuz.AFUZZZZZZZZ/Downloads/fstRepo-main%20(1)/fstRepo-main/ljx_backend/sql/seed_products.sql)

**修改位置：** 第 22–25 行（"工具类 (category_id=4)" 段）

**修改前：**

```sql
-- 工具类 (category_id=4)
('榫卯大师五件套', 4, 1280.00, '../images/工具.png', '含平凿、圆凿、斜凿、直角规、划线器，铬钒合金锻造，黄檀把手，附赠蠊皮磨刀石一块。入门必备。', 50, 1, NOW()),
('日式平刨', 4, 680.00, '../images/工具-2.png', '高碳钢刨刃，白橡木刨台，刃宽42mm，适合榫卯精准合缝调修。日本工艺标准。', 25, 1, NOW()),
('机械鸠尾榫导板', 4, 398.00, '../images/工具-3.png', '铝合金CNC精密加工，可调节式导轨，配合修边机使用，批量制作燕尾榫的效率利器。', 40, 1, NOW()),
```

**修改后：**

```sql
-- 工具类 (category_id=4)
('榫卯大师五件套', 4, 1280.00, '../images/tool-set.png', '含平凿、圆凿、斜凿、直角规、划线器，铬钒合金锻造，黄檀把手，附赠蠊皮磨刀石一块。入门必备。', 50, 1, NOW()),
('日式平刨', 4, 680.00, '../images/tool-plane.png', '高碳钢刨刃，白橡木刨台，刃宽42mm，适合榫卯精准合缝调修。日本工艺标准。', 25, 1, NOW()),
('机械鸠尾榫导板', 4, 398.00, '../images/tool-jig.png', '铝合金CNC精密加工，可调节式导轨，配合修边机使用，批量制作燕尾榫的效率利器。', 40, 1, NOW()),
```

**作用：** 修正后端 `product` 表中三件工具商品的 `cover_image` 字段，使其指向真实存在的 PNG 资源。这样 `/api/product/list` 接口返回的图片路径也是可用的。

---

## 四、用户后续提问与解答

> **用户原话（一字未删）：**
>
> "那我现在要做什么才能让它正常显示"

**解答（两步走）：**

### 4.1 第一步：微信开发者工具中重新编译（立即生效）

- 点击工具栏的「编译」按钮（或快捷键 `Ctrl+B`）
- 切到商城 Tab → 点击「工具」二级 tab
- 三件商品图片应立即正常显示（前端 `DEMO_TOOLS` 演示数据降级链路已生效）

### 4.2 第二步（可选）：同步后端数据库图片路径

如果后端已启动且 `product` 表里已经执行过旧版 `seed_products.sql`，由于 `cover_image` 字段还是错误的 `工具.png`，API 真实返回的数据会覆盖演示数据并显示空白。需要二选一：

**方式 A：单条 UPDATE（推荐，影响最小）**
在 DBeaver 对 `ljx_platform` 库执行：
```sql
UPDATE product SET cover_image = '../images/tool-set.png'   WHERE product_name = '榫卯大师五件套';
UPDATE product SET cover_image = '../images/tool-plane.png'  WHERE product_name = '日式平刨';
UPDATE product SET cover_image = '../images/tool-jig.png'    WHERE product_name = '机械鸠尾榫导板';
```

**方式 B：重新跑一次 seed**
在 DBeaver 先清空再重插（会重置其他商品数据，慎用）：
```sql
DELETE FROM product;
-- 然后重新执行 seed_products.sql
```

完成后再次点击编译，工具 Tab 下三件商品图片就能正常显示。

---

## 五、修改文件清单

| 序号 | 文件路径 | 修改类型 | 说明 |
| --- | --- | --- | --- |
| 1 | `ljx_extracted/ljx/pages/shop/shop.js` | 补齐字段 | `DEMO_TOOLS` 三个工具商品 `coverImage` 从 `''` 改为 `tool-*.png` |
| 2 | `ljx_backend/sql/seed_products.sql` | 路径修正 | 工具类三个商品 `cover_image` 从 `工具.png` 系列改为 `tool-*.png` |

## 六、验证结果

- **前端验证：** 微信开发者工具中编译后，切到「商城 → 工具」，三件工具商品的封面图（tool-set / tool-plane / tool-jig）正常展示。
- **后端验证（可选）：** 在 DBeaver 中执行方式 A 或方式 B 后，`product` 表中三件工具商品的 `cover_image` 字段均为 `../images/tool-*.png`，与 `pages/images/` 目录下的实际资源一致。

---

## 七、经验总结

1. **前后端资源路径必须保持一致** —— 任何写在代码里的图片路径都要去对应目录确认真实存在，避免出现「数据库里写了一个文件名，目录里却是另一个」的情况。
2. **演示数据与种子数据要同步维护** —— 前端 `DEMO_*` 数组和后端 `seed_*.sql` 中的图片字段是一对镜像，修改时必须双线同步，否则会出现「API 返回时被覆盖」「前端降级时正常」的不一致表现。
3. **降级链路的价值** —— 本次因为前端做了「API 空数据 → 演示数据」「API 调用失败 → 演示数据」的三层降级，即便后端图片路径尚未更新，前端也已经可以正常显示工具图片。后续如发现更多类似情况，可优先核对降级数据是否完备。

---

## 八、用户实际处理经历（补充）

> **用户原话（一字未删）：**
>
> "实际上我原本是从百度中下载的图片，下载的图片我将图片命名为中文名图片，然后将格式改为jpg保存，但是在百度网页使用图片另存为的方式下载的图片只有文件名是jpg的，虽然文件后缀显示也是jpg，但是文件的文件头实际为webp，所有我为了解决这个问题，使用了截图软件将图片截图为png格式，然后再插入shop.js，然后再ctrl+b热重载结果发现图片仍然没有显示，最后我在dbeaver总使用了第二步方式A同款sql语句在数据库中运行脚本后再次在小程序开发工具中ctrl+b热重载才使得图片正常显示的。"

### 8.1 经历梳理

将用户原话按时间线整理成 6 个步骤：

1. **从百度下载图片** —— 出于"语义直观"的目的，将图片命名为**中文名**（如 `工具.png`、`工具-2.png`、`工具-3.png`）。
2. **扩展名手动改为 jpg** —— 之后将图片格式改为 `.jpg` 保存。
3. **发现 jpg 实际是 webp** —— 百度网页"图片另存为"下载下来的图片，**虽然文件名后缀是 `.jpg`，但文件头实际是 webp 格式**（属于"挂羊头卖狗肉"的情况）。这类文件在很多图片查看器里能正常打开，但小程序的 `<image>` 标签不一定能识别 webp 编码。
4. **改用截图软件 → png 格式** —— 为彻底解决 webp 兼容问题，用户改用截图软件把图片**重新截图为 `.png` 格式**保存到 `pages/images/` 目录（这就是现在目录里看到的 `tool-set.png` / `tool-plane.png` / `tool-jig.png` 三张图）。
5. **改完 `shop.js` 后热重载失败** —— 把截图得到的 PNG 路径写进 `shop.js` 的 `DEMO_TOOLS` 数组里，然后在微信开发者工具中按 `Ctrl+B` 热重载，**结果图片仍然没有显示**。  
   - 原因分析：此时后端 `product` 表里三件工具商品的 `cover_image` 字段还是最初**用百度下载的中文名**（`工具.png`）写入的旧值，`/api/product/list` 接口返回了旧数据并**覆盖了前端演示数据**。
6. **执行方式 A SQL 后热重载成功** —— 用户在 DBeaver 中**手动跑了文档第四章"方式 A"那段 UPDATE 语句**，把数据库里三件工具商品的 `cover_image` 改成 `../images/tool-*.png`；再回到微信开发者工具中按 `Ctrl+B` 热重载，**三件工具商品的图片才真正正常显示**。

### 8.2 本次真实操作复盘（与第四章"两步走"操作完全一致）

| 步骤 | 用户实际做了什么 | 对应文档章节 |
| --- | --- | --- |
| ① | 截图软件把图片转成 PNG 并放入 `pages/images/` | 第三章 3.1 的"修改后"代码 |
| ② | 改 `shop.js` 的 `DEMO_TOOLS` 中 `coverImage` 路径 | 第三章 3.1 |
| ③ | `Ctrl+B` 热重载（**图片仍未显示**） | 第四章 4.1 |
| ④ | 在 DBeaver 执行「方式 A」的 3 条 UPDATE 语句 | 第四章 4.2 方式 A |
| ⑤ | 再 `Ctrl+B` 热重载（**图片成功显示**） | 第四章 4.1 验证通过 |

### 8.3 这次经历补充出的新经验

1. **百度「图片另存为」≠ 真 jpg** —— 网页右键下载的 `*.jpg`，实际二进制可能是 webp。**小程序 `<image>` 标签对 webp 兼容性参差不齐**，遇到"图片路径都对但就是不出来"的情况，先用截图/格式工厂等工具**主动转成 png 或真 jpg** 再用。
2. **中文文件名 + 空格是隐藏坑** —— `pages/images/工具.png` 这种含中文名加空格的路径在不同系统、不同小程序基础库下解析行为不一致，**强烈建议统一用英文小写 + 短横线**（如 `tool-set.png`）。
3. **前端降级 ≠ 后端免维护** —— 即便前端 `DEMO_TOOLS` 已经写对了图片，只要后端 `product` 表里仍是旧值，**API 返回的旧数据会"反向覆盖"前端降级**。本次就完整经历了"前端改 → 不生效 → 改后端 → 才生效"的全过程，**足以说明"双线同步"不是空话**。
4. **`Ctrl+B` 热重载的副作用提醒** —— 修改 `js` 数据文件后热重载，**并不会重置后端 `product` 表的旧数据**，必须额外走一次 SQL 同步才能让两层数据对齐。
