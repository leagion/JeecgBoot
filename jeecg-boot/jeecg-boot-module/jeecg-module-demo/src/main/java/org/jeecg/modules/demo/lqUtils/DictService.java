package org.jeecg.modules.demo.lqUtils;


import org.jeecg.modules.system.entity.SysDict;
import org.jeecg.modules.system.entity.SysDictItem;
import org.jeecg.modules.system.mapper.SysDictItemMapper;
import org.jeecg.modules.system.mapper.SysDictMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class DictService {

    @Autowired
    private SysDictMapper sysDictMapper;

    @Autowired
    private SysDictItemMapper sysDictItemMapper;

    // 根据字典编码和字典项值获取字典项名称
    public String getDictTextByCodeAndValue(String dictCode, String itemValue) {
        // 先根据字典编码查询字典 ID
        Map<String, Object> dictParams = new HashMap<>();
        dictParams.put("dict_code", dictCode);
        List<SysDict> dictList = sysDictMapper.selectByMap(dictParams);
        if (dictList.isEmpty()) {
            return null;
        }
        String dictId = dictList.get(0).getId();
      
        // 再根据字典 ID 和字典项值查询字典项名称
        Map<String, Object> itemParams = new HashMap<>();
        itemParams.put("dict_id", dictId);
        itemParams.put("item_value", itemValue);
        List<SysDictItem> itemList = sysDictItemMapper.selectByMap(itemParams);
        if (itemList.isEmpty()) {
            return null;
        }
        return itemList.get(0).getItemText();
    }

}